import SwiftUI

/// 右侧"相册"：一张贴在相册里的卡片（名字、年纪、做什么、跟谁过），下面是境况、本事、人、留着的东西
struct SidebarView: View {
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p

    var body: some View {
        let e = model.engine
        let s = model.story
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AlbumCard()

                section("境况") {
                    ForEach(s.units, id: \.key) { u in
                        let v = e.lookup(u.key)
                        let word = s.word(u.key, v)
                        MeterRow(
                            name: u.name, value: v - u.min, maxValue: max(1, u.max - u.min),
                            text: word.map { "\($0) · \(v)" } ?? "\(v)\(u.unit)",
                            tint: tint(for: u, value: v), delta: model.deltas[u.key], help: u.desc
                        )
                    }
                }

                section("本事") {
                    ForEach(s.stats, id: \.key) { st in
                        let v = e.lookup(st.key)
                        if st.max <= 10 {
                            PipRow(name: st.name, value: v, maxValue: st.max, delta: model.deltas[st.key], help: st.desc)
                        } else {
                            MeterRow(name: st.name, value: v, maxValue: st.max, text: "\(v)",
                                     tint: st.bad ? p.accent : p.khaki, delta: model.deltas[st.key], help: st.desc)
                        }
                    }
                }

                let people = s.persons.filter { e.lookup($0.key + "_met") != 0 }
                if !people.isEmpty {
                    section("人") {
                        ForEach(people, id: \.key) { person in
                            PersonRow(
                                name: person.name,
                                desc: person.desc,
                                trust: e.lookup(person.key),
                                dead: e.lookup(person.key + "_dead") != 0,
                                away: e.lookup(person.key + "_away") != 0,
                                delta: model.deltas[person.key]
                            )
                        }
                    }
                }

                let items = s.items.filter { e.lookup($0.key) > 0 }
                if !items.isEmpty {
                    section("留着的东西") {
                        ForEach(items, id: \.key) { item in
                            let n = e.lookup(item.key)
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("·").foregroundStyle(p.khaki)
                                Text(item.name + (n > 1 ? " ×\(n)" : ""))
                                    .font(Fonts.body(13.5))
                                    .foregroundStyle(p.ink)
                                if model.deltas[item.key] != nil {
                                    Text("新").font(Fonts.ui(9, .semibold)).foregroundStyle(p.accent)
                                }
                            }
                            .help(item.desc)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 62)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(p.panel.opacity(p.isDark ? 0.96 : 0.9))
        .overlay(alignment: .leading) { Rectangle().fill(p.line).frame(width: 1) }
    }

    /// 坏的一类（心结、烟、酒）越高越红；好的一类（健康、积蓄、心气）低于三成才变红
    private func tint(for u: StatDef, value v: Int) -> Color {
        let ratio = Double(v - u.min) / Double(max(1, u.max - u.min))
        if u.bad { return ratio >= 0.5 ? p.accent : p.inkDim }
        return ratio < 0.3 ? p.accent : p.khaki
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Text(title).font(Fonts.ui(11, .semibold)).tracking(3).foregroundStyle(p.inkFaint)
                Rectangle().fill(p.line).frame(height: 1)
            }
            content()
        }
    }
}

/// 相册里的一页：一条胶带、左上角打字机字的地名年份、右上角圆珠笔写的 "Tommy '69"
struct AlbumCard: View {
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p

    var body: some View {
        let e = model.engine
        let s = model.story
        let year = e.lookup("year")
        let changed = ["job", "family", "home"].contains { model.deltas[$0] != nil }
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text("MONVALE · PA")
                    .font(Fonts.typewriter(9))
                    .tracking(1)
                    .foregroundStyle(p.paperInk.opacity(0.55))
                Spacer()
                Text("Tommy '\(String(format: "%02d", ((year % 100) + 100) % 100))")
                    .font(Fonts.hand(13))
                    .foregroundStyle(Color(hex: 0x2C4A8A).opacity(0.85))
                    .rotationEffect(.degrees(-4))
            }
            Text(s.nick + "·" + (s.hero.components(separatedBy: "·").last ?? s.hero))
                .font(Fonts.bodyBold(23))
                .foregroundStyle(p.paperInk)
            Text(s.hero)
                .font(Fonts.doc(12.5))
                .foregroundStyle(p.paperInk.opacity(0.7))
            HStack(spacing: 6) {
                Text("\(e.lookup("age")) 岁").font(Fonts.bodyBold(14)).foregroundStyle(p.stamp)
                Text("·").foregroundStyle(p.paperInk.opacity(0.4))
                Text(s.label("job", e.lookup("job"))).font(Fonts.body(13.5)).foregroundStyle(p.paperInk)
                Text("·").foregroundStyle(p.paperInk.opacity(0.4))
                Text(s.label("family", e.lookup("family"))).font(Fonts.body(13.5)).foregroundStyle(p.paperInk)
                if changed {
                    Text("变动").font(Fonts.ui(9, .semibold)).foregroundStyle(p.stamp)
                }
            }
            .padding(.top, 2)
            Text("住在 " + s.label("home", e.lookup("home")) + " · \(year) 年")
                .font(Fonts.doc(12.5))
                .foregroundStyle(p.paperInk.opacity(0.62))
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PaperBackground())
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color(hex: 0xE8DDB5, alpha: 0.72))
                .frame(width: 78, height: 18)
                .rotationEffect(.degrees(-3))
                .offset(y: -8)
                .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        }
        .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
    }
}

struct DeltaBadge: View {
    let delta: Int?
    @Environment(\.palette) private var p

    var body: some View {
        if let delta, delta != 0 {
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(Fonts.mono(10.5).weight(.bold))
                .foregroundStyle(delta > 0 ? p.khaki : p.accent)
                .transition(.opacity)
        }
    }
}

struct MeterRow: View {
    let name: String
    let value: Int
    let maxValue: Int
    let text: String
    let tint: Color
    let delta: Int?
    let help: String
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(name).font(Fonts.body(13.5)).foregroundStyle(p.inkDim)
                Spacer()
                DeltaBadge(delta: delta)
                Text(text).font(Fonts.body(13.5)).foregroundStyle(p.ink).monospacedDigit()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(p.line.opacity(0.7))
                    Rectangle().fill(tint)
                        .frame(width: geo.size.width * CGFloat(max(0, min(value, maxValue))) / CGFloat(max(1, maxValue)))
                }
            }
            .frame(height: 3)
            .animation(.easeOut(duration: 0.6), value: value)
        }
        .help(help)
    }
}

struct PipRow: View {
    let name: String
    let value: Int
    let maxValue: Int
    let delta: Int?
    let help: String
    @Environment(\.palette) private var p

    var body: some View {
        HStack(alignment: .center) {
            Text(name).font(Fonts.body(13.5)).foregroundStyle(p.inkDim)
            Spacer()
            DeltaBadge(delta: delta)
            HStack(spacing: 3) {
                ForEach(0..<maxValue, id: \.self) { i in
                    Rectangle()
                        .fill(i < value ? p.ink.opacity(0.85) : p.line)
                        .frame(width: 8, height: 8)
                }
            }
            Text("\(value)").font(Fonts.mono(12).weight(.bold)).foregroundStyle(p.ink).frame(width: 18, alignment: .trailing)
        }
        .help(help)
    }
}

struct PersonRow: View {
    let name: String
    let desc: String
    let trust: Int
    let dead: Bool
    let away: Bool
    let delta: Int?
    @Environment(\.palette) private var p

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(name)
                    .font(Fonts.body(14))
                    .strikethrough(dead, color: p.inkFaint)
                    .foregroundStyle(dead ? p.inkFaint : p.ink)
                if dead {
                    Text("†").font(Fonts.bodyBold(13)).foregroundStyle(p.inkFaint)
                } else if away {
                    Text("不在身边").font(Fonts.ui(9.5)).foregroundStyle(p.inkFaint)
                }
                Spacer()
                if !dead {
                    DeltaBadge(delta: delta)
                    Text(trustWord).font(Fonts.ui(10.5)).foregroundStyle(p.inkFaint)
                }
            }
            if !dead {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(p.line.opacity(0.6))
                        Rectangle().fill(p.inkDim.opacity(0.8)).frame(width: geo.size.width * CGFloat(trust) / 100)
                    }
                }
                .frame(height: 2)
                .animation(.easeOut(duration: 0.6), value: trust)
            }
        }
        .help(desc)
        .opacity(dead ? 0.75 : 1)
    }

    private var trustWord: String {
        switch trust {
        case ..<20: return "冷了"
        case ..<40: return "疏远"
        case ..<60: return "一般"
        case ..<80: return "亲近"
        default: return "最亲"
        }
    }
}
