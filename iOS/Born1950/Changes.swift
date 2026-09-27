import Foundation

/// 一次抉择带来的一项变化，已经翻译成玩家看得懂的话。
/// Mac 版右边常驻"相册"侧栏，数值一变旁边就跳 +/-；手机上侧栏收进了弹出面板，
/// 所以每一屏正文开头挂一排小标签，告诉玩家上一个抉择改变了什么。
struct StatChange: Identifiable, Equatable {
    enum Kind: Int, Comparable {
        case life      // 做什么、跟谁过、住在哪儿
        case unit      // 境况：健康、积蓄、心气、心结、烟、酒
        case person    // 跟某个人亲不亲
        case stat      // 本事：头脑、手艺、体格、胆量、心肠
        case item      // 留着的东西

        static func < (a: Kind, b: Kind) -> Bool { a.rawValue < b.rawValue }
    }

    enum Tone { case good, bad, neutral }

    let key: String       // 剧本里的变量名：health、ray、nerve、i_tag、job……
    let kind: Kind
    let name: String      // 显示名：健康、雷·科斯塔、胆量、柯蒂斯的狗牌、职业……
    let delta: Int        // 变化量（新值 − 旧值）
    let range: Int        // 这个数值的量程（上限 − 下限）：同样 +3，放在 0–10 的胆量上和 0–100 的健康上分量完全不同
    let tone: Tone        // 对玩家是好事、坏事还是说不上
    let label: String     // 芯片上的整句："健康 −3"、"雷·科斯塔 亲近 +5"、"职业 → 钢厂工人"、"留下 柯蒂斯的狗牌"

    var id: String { key }
}

extension StatChange {
    /// 把 GameModel.deltas（变量名 → 变化量）翻译成 StatChange 列表，顺序和相册里一致
    static func all(from deltas: [String: Int], engine: Engine, story: Story) -> [StatChange] {
        guard !deltas.isEmpty else { return [] }
        var out: [StatChange] = []

        // 职业、婚姻、住处是枚举：变了就报新的那一项，说不上好坏（"待业""服刑""退休"也是职业）
        for (key, name) in [("job", "职业"), ("family", "婚姻"), ("home", "住处")] {
            guard let d = deltas[key], d != 0 else { continue }
            let now = story.label(key, engine.lookup(key))
            out.append(StatChange(key: key, kind: .life, name: name, delta: d,
                                  range: max(1, (story.enums[key]?.count ?? 1) - 1),
                                  tone: .neutral, label: "\(name) → \(now)"))
        }
        // 境况里心结、烟、酒是越高越糟（剧本里标了 bad）
        for u in story.units {
            guard let d = deltas[u.key], d != 0 else { continue }
            out.append(StatChange(key: u.key, kind: .unit, name: u.name, delta: d, range: u.max - u.min,
                                  tone: (d > 0) != u.bad ? .good : .bad, label: "\(u.name) \(signed(d))"))
        }
        for person in story.persons {
            guard let d = deltas[person.key], d != 0 else { continue }
            out.append(StatChange(key: person.key, kind: .person, name: person.name, delta: d, range: 100,
                                  tone: d > 0 ? .good : .bad, label: "\(person.name) 亲近 \(signed(d))"))
        }
        for s in story.stats {
            guard let d = deltas[s.key], d != 0 else { continue }
            out.append(StatChange(key: s.key, kind: .stat, name: s.name, delta: d, range: s.max - s.min,
                                  tone: (d > 0) != s.bad ? .good : .bad, label: "\(s.name) \(signed(d))"))
        }
        for item in story.items {
            guard let d = deltas[item.key], d != 0 else { continue }
            out.append(StatChange(key: item.key, kind: .item, name: item.name, delta: d, range: 1,
                                  tone: .neutral, label: d > 0 ? "留下 \(item.name)" : "失去 \(item.name)"))
        }
        return out
    }

    /// 用真正的减号（−）而不是连字符，数字对齐也好看些
    static func signed(_ d: Int) -> String { d > 0 ? "+\(d)" : "−\(-d)" }
}

/// 手机顶上只有窄窄一条地方。这里决定：一次抉择引起的全部变化里，哪些值得立刻告诉玩家、按什么顺序。
/// 没挑上的不会丢——标签条末尾会出一个"另 N 项"，点开就是完整的相册。
///
/// 这个游戏特有的情况：剧本每把 year 往前推一次，引擎就按 Aging.toll 一年一年扣健康，
/// 所以跨年的那个抉择总会顺带一个"健康 −N"——它是岁月扣的，不是这个选择本身的后果。
///
/// - Parameter all: 这次抉择引起的全部变化，已按 职业/婚姻/住处 → 境况 → 人 → 本事 → 东西 排好
/// - Returns: 要显示在正文开头的那几项，按显示顺序
func pickHeadlineChanges(_ all: [StatChange]) -> [StatChange] {
    // TODO: 挑选规则还没定。现在是全部照搬（"那几年"的随机事件一次能变五六项，会折成两三行）。
    return all
}
