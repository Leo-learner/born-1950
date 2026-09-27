// 岁月在身上留下的痕迹（Mac 版 Sources/Aging.swift 的移植，两边的公式要保持一致）。
// 剧本每次把 year 往前推（@set year = 1976），引擎就对跨过去的每一年调用一次 toll，
// 把返回值从健康里扣掉。所以烟、酒、体格不只在某一个抉择里起作用——它们是一年一年攒出来的。
//
// 参照：健康初值 85；剧本里的大事件（受伤、戒烟、生病）一次加减 5—30。
// 第六部会检查健康：新冠那年健康低于 25 很危险，2026 年低于 10 活不到最后一章。

/**
 * @param age   这一年的岁数（0 = 1950 年）
 * @param smoke 烟瘾 0—100（30 大约一天半包，70 是两包）
 * @param drink 酒瘾 0—100
 * @param body  体格 0—10
 * @returns 这一年要扣掉的健康点数（≥ 0）
 */
export function toll(age, smoke, drink, body) {
  // 占位版本（和 Mac 版一样，调过平衡）：四十岁以后隔一年扣 1，六十岁以后每年扣 1；
  // 烟从三十五岁起开始算账（烟瘾 40 大约每年多扣 1），酒每 50 点多扣 1；体格好的人六十岁以前少扣。
  if (age < 35) return 0;
  let t = 0;
  if (age >= 60) t += 1;
  else if (age >= 40 && age % 2 === 0) t += 1;
  t += Math.trunc(smoke / 40) + Math.trunc(drink / 50);
  if (body >= 7 && age < 60) t -= 1;
  return Math.max(0, t);
}
