'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { STATES, STATE_ORDER, SCALE_PRESETS, normalizeScale, normalizeState } = require('../lib/states');
const { parseSessionText } = require('../lib/session');

const fixtures = path.join(__dirname, 'fixtures');
const read = (name) => fs.readFileSync(path.join(fixtures, `${name}.jsonl`), 'utf8');

assert.deepEqual(STATE_ORDER, ['idle', 'wave', 'cry', 'angry', 'waiting', 'running', 'review']);
assert.equal(Object.keys(STATES).length, 7);
assert.deepEqual(SCALE_PRESETS, [0.5, 0.75, 1, 1.5, 2]);
assert.equal(normalizeState('unknown'), 'idle');
assert.equal(normalizeScale(3), 1);

assert.equal(parseSessionText(read('running'), new Date()), 'running');
assert.equal(parseSessionText(read('waiting'), new Date()), 'waiting');
assert.equal(parseSessionText(read('complete'), new Date()), 'review');
assert.equal(parseSessionText(read('failed'), new Date()), 'cry');
assert.equal(parseSessionText(read('corrupt'), new Date()), 'idle');
assert.equal(parseSessionText(read('running'), new Date(Date.now() - 25 * 60 * 60 * 1000)), 'idle');

const mainSource = fs.readFileSync(path.join(__dirname, '..', 'main.js'), 'utf8');
for (const forbidden of ['QuotaSnapshot', 'rate_limits', 'token_count', 'showQuota']) {
  assert.equal(mainSource.includes(forbidden), false, `不得包含额度功能：${forbidden}`);
}
for (const required of ['show-context-menu', 'drag-start', 'set-scale', '退出咕咕龙桌宠', "tray.setToolTip(PRODUCT_NAME)", 'speakOccasionally']) {
  assert.equal(mainSource.includes(required), true, `缺少关键交互：${required}`);
}

console.log(JSON.stringify({
  ok: true,
  actions: STATE_ORDER,
  scales: SCALE_PRESETS,
  fixtures: ['running', 'waiting', 'complete', 'failed', 'corrupt', 'stale'],
  quotaFeature: false
}, null, 2));
