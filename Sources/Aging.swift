import Foundation

/// 岁月在身上留下的痕迹。
/// 剧本每次把 year 往前推（@set year = 1976），引擎就对跨过去的每一年调用一次 toll，
/// 把返回值从健康里扣掉。所以烟、酒、体格不只在某一个抉择里起作用——它们是一年一年攒出来的。
///
/// 参照：健康初值 85；剧本里的大事件（受伤、戒烟、生病）一次加减 5—30。
/// 第六部会检查健康：新冠那年健康低于 25 很危险，2026 年低于 10 活不到最后一章。
enum Aging {
    /// - Parameters:
    ///   - age: 这一年的岁数（0 = 1950 年）
    ///   - smoke: 烟瘾 0—100（30 大约一天半包，70 是两包）
    ///   - drink: 酒瘾 0—100
    ///   - body: 体格 0—10
    /// - Returns: 这一年要扣掉的健康点数（≥ 0）
    static func toll(age: Int, smoke: Int, drink: Int, body: Int) -> Int {
        // TODO(你来定)：这是整个人生模拟的"物理定律"。
        // 下面是能跑通的占位版本：四十岁以后隔一年扣 1，六十岁以后每年扣 1；
        // 烟从三十五岁起开始算账（烟瘾 40 大约每年多扣 1），酒每 50 点多扣 1；体格好的人六十岁以前少扣。
        // 改完以后跑一遍 tests/*.walk 和 -probe "b6_2020:health"，看真结局那条路还活不活得到 2026 年。
        guard age >= 35 else { return 0 }
        var toll = 0
        if age >= 60 { toll += 1 } else if age >= 40 && age % 2 == 0 { toll += 1 }
        toll += smoke / 40 + drink / 50
        if body >= 7 && age < 60 { toll -= 1 }
        return max(0, toll)
    }
}
