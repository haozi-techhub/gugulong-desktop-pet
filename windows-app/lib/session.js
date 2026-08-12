'use strict';

const fs = require('node:fs');
const path = require('node:path');

const MAX_TAIL_BYTES = 1024 * 1024;
const STALE_AFTER_MS = 24 * 60 * 60 * 1000;

function parseSessionText(text, modifiedAt = new Date()) {
  if (typeof text !== 'string') return 'idle';
  let state = 'idle';
  let stateTimestamp = '';
  let taskActive = false;

  for (const line of text.split(/\r?\n/)) {
    if (line.length < 2) continue;
    let json;
    try {
      json = JSON.parse(line);
    } catch {
      continue;
    }
    const timestamp = typeof json.timestamp === 'string' ? json.timestamp : '';
    const payload = json.payload && typeof json.payload === 'object' ? json.payload : {};
    const outerType = typeof json.type === 'string' ? json.type : '';
    const type = typeof payload.type === 'string' ? payload.type : '';

    if (outerType === 'event_msg' && timestamp >= stateTimestamp) {
      if (type === 'task_started') {
        state = 'running';
        taskActive = true;
        stateTimestamp = timestamp;
      } else if (type === 'task_complete') {
        state = 'review';
        taskActive = false;
        stateTimestamp = timestamp;
      } else if (type.includes('failed') || type.includes('error')) {
        state = 'cry';
        taskActive = false;
        stateTimestamp = timestamp;
      }
    }

    const toolName = typeof payload.name === 'string' ? payload.name : '';
    const waiting = type === 'approval_request' || type === 'mcp_elicitation' ||
      (outerType === 'response_item' && type === 'custom_tool_call' &&
        (toolName === 'request_permissions' || toolName === 'request_user_input'));
    if (waiting && timestamp >= stateTimestamp) {
      state = 'waiting';
      taskActive = true;
      stateTimestamp = timestamp;
    }
  }

  const modifiedMs = modifiedAt instanceof Date ? modifiedAt.getTime() : Number(modifiedAt);
  if (Number.isFinite(modifiedMs) && Date.now() - modifiedMs > STALE_AFTER_MS) return 'idle';
  if (!taskActive && state === 'running') return 'idle';
  return state;
}

function readTail(filePath) {
  const stat = fs.statSync(filePath);
  const length = Math.min(stat.size, MAX_TAIL_BYTES);
  const offset = Math.max(0, stat.size - length);
  const descriptor = fs.openSync(filePath, 'r');
  try {
    const buffer = Buffer.alloc(length);
    fs.readSync(descriptor, buffer, 0, length, offset);
    let text = buffer.toString('utf8');
    if (offset > 0) {
      const newline = text.indexOf('\n');
      if (newline >= 0) text = text.slice(newline + 1);
    }
    return text;
  } finally {
    fs.closeSync(descriptor);
  }
}

function isMainSession(filePath) {
  try {
    const descriptor = fs.openSync(filePath, 'r');
    const buffer = Buffer.alloc(16384);
    const length = fs.readSync(descriptor, buffer, 0, buffer.length, 0);
    fs.closeSync(descriptor);
    const firstLine = buffer.subarray(0, length).toString('utf8').split(/\r?\n/, 1)[0];
    const meta = JSON.parse(firstLine);
    const payload = meta && typeof meta.payload === 'object' ? meta.payload : {};
    const source = payload && typeof payload.source === 'object' ? payload.source : {};
    return payload.thread_source !== 'subagent' && !source.subagent;
  } catch {
    return true;
  }
}

function collectJsonl(root, output = []) {
  if (!fs.existsSync(root)) return output;
  let entries;
  try {
    entries = fs.readdirSync(root, { withFileTypes: true });
  } catch {
    return output;
  }
  for (const entry of entries) {
    const fullPath = path.join(root, entry.name);
    if (entry.isDirectory()) collectJsonl(fullPath, output);
    else if (entry.isFile() && entry.name.toLowerCase().endsWith('.jsonl')) output.push(fullPath);
  }
  return output;
}

function latestMainSession(root) {
  let best = null;
  let bestMtime = -1;
  for (const filePath of collectJsonl(root)) {
    try {
      const mtime = fs.statSync(filePath).mtimeMs;
      if (mtime <= bestMtime || !isMainSession(filePath)) continue;
      best = filePath;
      bestMtime = mtime;
    } catch {
      // A session may disappear while Codex rotates files; ignore it safely.
    }
  }
  return best;
}

function readLatestState(root) {
  const filePath = latestMainSession(root);
  if (!filePath) return { state: 'idle', sourcePath: null };
  try {
    const stat = fs.statSync(filePath);
    return { state: parseSessionText(readTail(filePath), stat.mtime), sourcePath: filePath };
  } catch {
    return { state: 'idle', sourcePath: null };
  }
}

module.exports = { parseSessionText, readTail, latestMainSession, readLatestState };
