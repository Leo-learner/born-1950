// node --test tests/engine.test.mjs   剧本引擎的回归测试：按攻略走到真结局，衰老与分档词，静态检查 + 小规模模拟不卡死
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { loadStoryDir, check } from '../tools/check.mjs';
import { walk } from '../tools/walk.mjs';
import { parseExpr, evaluate } from '../web/src/expr.js';
import { Engine, SplitMix, newMeta } from '../web/src/engine.js';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const story = loadStoryDir(path.join(root, 'story'));
const quiet = () => {};

test('剧本解析没有问题', () => {
  assert.deepEqual(story.issues, []);
  assert.equal(story.endings.length, 36);
  assert.equal(story.docs.length, 48);
  assert.equal(story.born, 1950);
  assert.deepEqual(story.units.filter(u => u.bad).map(u => u.key), ['guilt', 'smoke', 'drink']);
});

test('表达式：比较、逻辑、整除', () => {
  const ctx = { lookup: n => ({ a: 7, b: 2 })[n] ?? 0, call: () => 0 };
  const v = s => evaluate(parseExpr(s), ctx);
  assert.equal(v('a == 7 && b != 3'), 1);
  assert.equal(v('a < b || !(b >= 2)'), 0);
  assert.equal(v('-a / b'), -3);
  assert.equal(v('a % b + 2 * 3'), 7);
  assert.equal(v('a / 0'), 0);
});

test('SplitMix64 符合标准测试向量（Swift 版是同一个算法）', () => {
  const r = new SplitMix(0n);
  assert.equal(r.next(), 0xE220A8397B1DCDAFn);
  assert.equal(r.next(), 0x6E789E6AA1B965F4n);
});

test('年份往前走时按 Aging.toll 逐年扣健康，age 跟着 year 走', () => {
  const e = new Engine(story, newMeta());
  e.state.vars = { ...story.initial };
  e.set('smoke', 40);
  e.set('year', 1990);            // 35–39 岁：只有烟在扣，每年 1
  assert.equal(e.lookup('age'), 40);
  assert.equal(e.lookup('health'), 85 - 5);
  e.set('year', 2000);            // 40–49 岁：双数年再扣 1，烟每年 1
  assert.equal(e.lookup('health'), 80 - 15);
  e.set('year', 1995);            // 往回拨不扣
  assert.equal(e.lookup('health'), 65);
});

test('分档词和插值：{~money} {#job} {age}', () => {
  const e = new Engine(story, newMeta());
  e.state.vars = { ...story.initial, money: 25, job: 2, year: 1969 };
  assert.equal(e.interpolate('{~money}·{#job}·{age}岁'), '紧巴·钢厂工人·19岁');
  e.set('money', 100);
  assert.equal(e.interpolate('{~money}'), '富有');
});

test('攻略 true_ending.walk 走到 e34', () => {
  const { ok, engine } = walk(story, readFileSync(path.join(root, 'tests', 'true_ending.walk'), 'utf8'), quiet);
  assert.ok(ok);
  assert.equal(engine.state.ending, 'e34');
});

test('静态检查 + 300 局模拟：没有错误、没有卡死', () => {
  const { errors, sim } = check(story, { runs: 300, seed: 42n, log: quiet });
  assert.deepEqual(errors, []);
  assert.deepEqual(sim.broken, {});
  assert.equal(sim.loops, 0);
});
