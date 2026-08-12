'use strict';

const STATES = Object.freeze({
  idle: Object.freeze({ label: '默认', row: 0, frames: 6, interval: 250, idleHoldTicks: 7 }),
  wave: Object.freeze({ label: '挥爪', row: 3, frames: 4, interval: 240 }),
  cry: Object.freeze({ label: '大哭', row: 5, frames: 8, interval: 240 }),
  angry: Object.freeze({ label: '暴怒跺脚', row: 4, frames: 5, interval: 220 }),
  waiting: Object.freeze({ label: '等待', row: 6, frames: 6, interval: 260 }),
  running: Object.freeze({ label: '执行中', row: 7, frames: 6, interval: 180 }),
  review: Object.freeze({ label: '点赞', row: 8, frames: 6, interval: 240 })
});

const STATE_ORDER = Object.freeze(['idle', 'wave', 'cry', 'angry', 'waiting', 'running', 'review']);
const SCALE_PRESETS = Object.freeze([0.5, 0.75, 1, 1.5, 2]);

function normalizeState(value) {
  return Object.prototype.hasOwnProperty.call(STATES, value) ? value : 'idle';
}

function normalizeScale(value) {
  const numeric = Number(value);
  return SCALE_PRESETS.includes(numeric) ? numeric : 1;
}

module.exports = { STATES, STATE_ORDER, SCALE_PRESETS, normalizeState, normalizeScale };
