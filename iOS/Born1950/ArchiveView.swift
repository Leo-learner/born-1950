import SwiftUI

/// 鞋盒：结局图鉴 + 旧物
struct ArchiveView: View {
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let compact = sizeClass != .regular
        ZStack {
            AtmosphereView(mood: "basement")
            VStack(spacing: 0) {
                header(compact)
                Group {
                    if model.archiveTab == 0 { EndingGallery() } else { DocBrowser() }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        // 手机上旧物不分栏：点一个信封，从底下抽出来一张纸；下滑放回去
        .sheet(item: Binding(
            get: { compact ? model.archiveDoc.map(DocRef.init) : nil },
            set: { model.archiveDoc = $0?.id }
        )) { ref in
            DocSheet(id: ref.id)
                .environmentObject(model)
                .environment(\.palette, p)
                .presentationDragIndicator(.visible)
                .presentationBackground(p.bg)
                .preferredColorScheme(p.isDark ? .dark : .light)
        }
    }

    private func header(_ compact: Bool) -> some View {
        let keyDocs = model.story.docs.filter(\.isKey)
        let keyFound = keyDocs.filter { model.engine.meta.docs[$0.id] != nil }.count
        let percent = model.story.docs.isEmpty ? 0 : model.docCount * 100 / model.story.docs.count
        let back = Button { model.closeArchive() } label: {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left").font(.system(size: 15, weight: .semibold))
                Text("返回")
            }
            .font(Fonts.body(15))
            .foregroundStyle(p.inkDim)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        let progress = VStack(alignment: .trailing, spacing: 3) {
            Text("拼回 \(percent)%").font(Fonts.bodyBold(14)).foregroundStyle(p.ink)
            Text("关键旧物 \(keyFound)/\(keyDocs.count)").font(Fonts.ui(11)).foregroundStyle(keyFound == keyDocs.count ? p.gold : p.inkFaint)
        }
        let picker = Picker("", selection: $model.archiveTab) {
            Text("结局 \(model.endingCount)/\(model.story.endings.count)").tag(0)
            Text("旧物 \(model.docCount)/\(model.story.docs.count)").tag(1)
        }
        .pickerStyle(.segmented)

        return Group {
            if compact {
                VStack(spacing: 10) {
                    HStack(alignment: .center, spacing: 14) {
                        back
                        Text("鞋盒").font(Fonts.bodyBold(21)).foregroundStyle(p.ink)
                        Spacer()
                        progress
                    }
                    picker
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
            } else {
                HStack(alignment: .center, spacing: 22) {
                    back
                    Text("鞋盒").font(Fonts.bodyBold(22)).foregroundStyle(p.ink)
                    picker.frame(width: 330)
                    Spacer()
                    progress
                }
                .padding(.horizontal, 28)
                .frame(height: 64)
            }
        }
        .background(p.bg.opacity(0.6).ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) { Rectangle().fill(p.line).frame(height: 1) }
    }
}

private struct DocRef: Identifiable {
    let id: String
}

// MARK: - 结局图鉴

struct EndingGallery: View {
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p
    @Environment(\.horizontalSizeClass) private var sizeClass
    @AppStorage(Prefs.hints) private var hints = true

    private let acts: [(Int, String)] = [
        (1, "第一部 · 河谷 · 1950—1962"),
        (2, "第二部 · 收音机 · 1963—1968"),
        (3, "第三部 · 号码 · 1969—1975"),
        (4, "第四部 · 关厂 · 1976—1989"),
        (5, "第五部 · 千禧 · 1990—2007"),
        (6, "第六部 · 窗外 · 2008—2026"),
        (0, "鞋盒之外"),
    ]

    var body: some View {
        let compact = sizeClass != .regular
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ForEach(acts, id: \.0) { act, title in
                    let list = model.story.endings.filter { $0.act == act }
                    if !list.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Text(title).font(Fonts.bodyBold(16)).foregroundStyle(p.inkDim).fixedSize()
                                Rectangle().fill(p.line).frame(height: 1)
                            }
                            // 不设上限：手机上单列铺满，iPad 上按 230pt 自动分列
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 230), spacing: 12)], spacing: 12) {
                                ForEach(list) { ending in
                                    EndingCard(ending: ending, showHint: hints || model.engine.meta.runsFinished > 0)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, compact ? 16 : 40)
            .padding(.vertical, compact ? 18 : 28)
        }
        .scrollIndicators(.hidden)
    }
}

struct EndingCard: View {
    let ending: EndingDef
    let showHint: Bool
    @EnvironmentObject private var model: GameModel

    var body: some View {
        let unlocked = model.engine.meta.endings[ending.id] != nil
        Button {
            guard unlocked else { return }
            model.markSeen(ending: ending.id)
            if let doc = ending.doc { model.openArchive(tab: 1, doc: doc) }
        } label: {
            EndingCardLabel(ending: ending, showHint: showHint)
        }
        .buttonStyle(PressAware())
    }
}

private struct EndingCardLabel: View {
    let ending: EndingDef
    let showHint: Bool
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p
    @Environment(\.buttonPressed) private var pressed

    var body: some View {
        let date = model.engine.meta.endings[ending.id]
        let unlocked = date != nil
        let isNew = model.engine.meta.unseenEndings.contains(ending.id)
        let tint = p.tier(ending.tier)
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ending.tier).font(Fonts.typewriter(12).weight(.bold)).foregroundStyle(unlocked ? tint : p.inkFaint)
                Text(Palette.tierName(ending.tier)).font(Fonts.ui(10.5)).foregroundStyle(p.inkFaint)
                Spacer()
                if isNew { Text("新").font(Fonts.ui(10, .semibold)).foregroundStyle(p.accent) }
                Text(ending.id.uppercased()).font(Fonts.typewriter(10)).foregroundStyle(p.inkFaint)
            }
            Text(unlocked ? ending.title : "？？？")
                .font(Fonts.bodyBold(19))
                .foregroundStyle(unlocked ? p.ink : p.inkFaint)
            if unlocked, let date {
                Text("首次抵达 " + date.formatted(date: .abbreviated, time: .omitted))
                    .font(Fonts.ui(10.5))
                    .foregroundStyle(p.inkFaint)
            } else if showHint {
                Text(ending.hint)
                    .font(Fonts.body(13))
                    .foregroundStyle(p.inkFaint)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 4).fill(unlocked ? (pressed ? p.panelHi : p.panel) : p.panel.opacity(0.45)))
        .overlay(alignment: .top) {
            Rectangle().fill(unlocked ? tint : p.line).frame(height: 2)
        }
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(pressed && unlocked ? tint.opacity(0.6) : p.line, lineWidth: 1))
        .contentShape(Rectangle())
    }
}

// MARK: - 旧物

struct DocBrowser: View {
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            HStack(spacing: 0) {
                list
                    .frame(width: 320)
                    .background(p.panel.opacity(0.7))
                    .overlay(alignment: .trailing) { Rectangle().fill(p.line).frame(width: 1) }
                ScrollView {
                    Group {
                        if let id = model.archiveDoc {
                            DocDetail(id: id)
                        } else {
                            VStack(spacing: 14) {
                                Image(systemName: "shippingbox").font(.system(size: 34)).foregroundStyle(p.inkFaint)
                                Text("从左边选一个信封").font(Fonts.body(15)).foregroundStyle(p.inkFaint)
                                Text("每一个结局，都是某个人真实的结局。")
                                    .font(Fonts.body(13))
                                    .foregroundStyle(p.inkFaint.opacity(0.8))
                            }
                            .padding(.top, 140)
                        }
                    }
                    .frame(maxWidth: 660)
                    .padding(36)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
        } else {
            list
        }
    }

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(model.story.docs) { doc in
                    row(doc)
                    if sizeClass != .regular {
                        Rectangle().fill(p.line.opacity(0.5)).frame(height: 1).padding(.leading, 106)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func row(_ doc: DocDef) -> some View {
        let unlocked = model.engine.meta.docs[doc.id] != nil
        let selected = sizeClass == .regular && model.archiveDoc == doc.id
        let isNew = model.engine.meta.unseenDocs.contains(doc.id)
        return Button {
            model.archiveDoc = doc.id
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                // "DK_WOODSTOCK" 这种长编号在 58pt 里会折行，放宽并允许略缩
                Text(doc.id.uppercased())
                    .font(Fonts.typewriter(10.5))
                    .foregroundStyle(p.inkFaint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: 80, alignment: .leading)
                if unlocked {
                    Text(doc.title)
                        .font(Fonts.body(15))
                        .foregroundStyle(selected ? p.ink : p.inkDim)
                        .lineLimit(1)
                } else {
                    Text(String(repeating: "█", count: max(4, min(12, doc.title.count))))
                        .font(Fonts.body(12))
                        .foregroundStyle(p.line)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if doc.isKey { Image(systemName: "star.fill").font(.system(size: 9)).foregroundStyle(unlocked ? p.gold : p.inkFaint) }
                if isNew { Circle().fill(p.accent).frame(width: 6, height: 6) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(selected ? p.panelHi : .clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(unlocked ? "\(doc.id.uppercased())，\(doc.title)" : "\(doc.id.uppercased())，还没拆开")
    }
}

/// 一件旧物：拆开了就是那张纸，没拆开就是信封的背面
struct DocDetail: View {
    let id: String
    @EnvironmentObject private var model: GameModel
    @Environment(\.palette) private var p

    var body: some View {
        if let doc = model.story.doc(id) {
            if model.engine.meta.docs[id] != nil {
                DocCard(doc: doc)
                    .onAppear { model.markSeen(doc: id) }
            } else {
                lockedCard(doc)
            }
        }
    }

    private func lockedCard(_ doc: DocDef) -> some View {
        let source = model.story.endings.first { $0.doc == doc.id }
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("№ \(doc.id.uppercased())").font(Fonts.typewriter(12)).foregroundStyle(p.paperInk.opacity(0.5))
                Spacer()
                Text("？？？").font(Fonts.marker(26)).foregroundStyle(p.paperInk.opacity(0.35)).rotationEffect(.degrees(-6))
            }
            // 信封背面的三角封口：按宽度画，窄屏宽屏都是一个信封
            EnvelopeFlap()
                .stroke(p.paperInk.opacity(0.25), lineWidth: 1.5)
                .frame(height: 96)
            Text(source.map { "某一次重来走到结局「\(model.engine.meta.endings[$0.id] != nil ? $0.title : "？？？")」时，这个信封会被拆开。" }
                 ?? "这个信封夹在某一段人生的路上。")
                .font(Fonts.doc(14))
                .foregroundStyle(p.paperInk.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 10)
        }
        .padding(26)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PaperBackground())
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

/// 信封封口：从左上角斜到底边中点，再斜回右上角
private struct EnvelopeFlap: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        return path
    }
}

/// 手机上从鞋盒里抽出来的那张纸
struct DocSheet: View {
    let id: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                HStack {
                    Spacer()
                    TextAction(title: "放回去", strong: true) { dismiss() }
                }
                DocDetail(id: id)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
    }
}
