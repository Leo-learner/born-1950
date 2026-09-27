import SwiftUI

struct TitleView: View {
    @EnvironmentObject private var model: GameModel
    @EnvironmentObject private var fonts: FontLoader
    @Environment(\.palette) private var p
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        let compact = sizeClass != .regular
        ZStack {
            AtmosphereView(mood: "mill")

            Text("1950")
                .font(Fonts.typewriter(compact ? 230 : 400).weight(.bold))
                .foregroundStyle(p.ink.opacity(0.035))
                .fixedSize()
                // minWidth/minHeight 必须写 0：不写的话 frame 的下限默认是子视图的宽度（这串字五六百 pt），
                // 整个 ZStack 会被撑宽、内容被挤出屏幕
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: compact ? .bottomTrailing : .trailing)
                .offset(x: compact ? 60 : 60, y: compact ? -170 : 40)
                .allowsHitTesting(false)
                .accessibilityHidden(true)

            if !compact {
                // iPad 和 Mac 一样：盒盖斜放在右下角
                ShoeboxLid(label: "NOT MINE")
                    .frame(width: 330, height: 220)
                    .rotationEffect(.degrees(-6))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 90)
                    .padding(.bottom, 110)
                    .opacity(0.9)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }

            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if compact {
                            // 手机竖屏放不下"左边文字、右下盒盖"：盒盖挪到最上面，像先看见那只鞋盒，再看见名字
                            ShoeboxLid(label: "NOT MINE")
                                .frame(width: 330, height: 220)
                                .scaleEffect(0.62)
                                .frame(width: 205, height: 136)
                                .rotationEffect(.degrees(-6))
                                .opacity(0.92)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.top, 26)
                                .padding(.trailing, -6)
                                .accessibilityHidden(true)
                        } else {
                            Spacer(minLength: 70)
                        }
                        heading(compact).padding(.top, compact ? 10 : 0)
                        menu.padding(.top, compact ? 34 : 46)
                        Spacer(minLength: 36)
                        footer
                    }
                    .padding(.horizontal, compact ? 28 : 100)
                    .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize)
                .scrollIndicators(.hidden)
                // 小屏手机上标题页也要滚动
                .fadesUnderStatusBar()
            }
        }
    }

    private func heading(_ compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("MONVALE, PENNSYLVANIA  ·  1950 — 2026")
                .font(Fonts.typewriter(compact ? 10.5 : 12))
                .tracking(compact ? 2 : 4)
                .foregroundStyle(p.inkFaint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text("生于一九五〇")
                .font(Fonts.display(compact ? 46 : 70))
                .foregroundStyle(p.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.top, compact ? 12 : 16)
            HStack(spacing: 14) {
                Rectangle().fill(p.accent).frame(width: compact ? 50 : 70, height: 3)
                Text("鞋 盒 里 的 美 国").font(Fonts.bodyBold(compact ? 17 : 19)).foregroundStyle(p.inkDim)
            }
            .padding(.top, 10)
            Text("一个钢铁镇男孩的七十六年，\n和一只写着\u{201C}不是我的\u{201D}的鞋盒。")
                .font(Fonts.body(compact ? 15 : 16))
                .lineSpacing(compact ? 7 : 8)
                .foregroundStyle(p.inkDim)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, compact ? 20 : 26)
        }
    }

    private var menu: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let auto = model.autosave {
                TitleMenuItem(title: "继续", detail: [auto.chapter, auto.date].filter { !$0.isEmpty }.joined(separator: " · ")) {
                    model.continueGame()
                }
            }
            TitleMenuItem(title: "新的一生", detail: model.engine.meta.runsStarted == 0 ? "1950年3月17日，星期五" : "第 \(model.engine.meta.runsStarted + 1) 次重来") {
                model.sheet = .newGame
            }
            TitleMenuItem(title: "读取存档", detail: nil) { model.sheet = .load }
            TitleMenuItem(
                title: "鞋盒",
                detail: "结局 \(model.endingCount)/\(model.story.endings.count) · 旧物 \(model.docCount)/\(model.story.docs.count)",
                badge: model.unseenCount > 0
            ) { model.openArchive() }
            TitleMenuItem(title: "设置", detail: nil) { model.sheet = .settings }
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if fonts.phase != .ready {
                // 下载中只是提示；卡住、没网、失败时点一下立刻重试
                Button {
                    fonts.start(force: true)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if fonts.isBusy {
                            ProgressView().controlSize(.mini)
                        } else {
                            Image(systemName: fonts.phase == .waitingForWiFi ? "wifi" : "arrow.clockwise")
                                .font(.system(size: 11))
                                .foregroundStyle(p.accent)
                        }
                        Text(fonts.statusText)
                            .font(Fonts.ui(11))
                            .foregroundStyle(fonts.isBusy ? p.inkDim : p.accent)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .buttonStyle(.plain)
                .disabled(fonts.isBusy)
            }
            Text("本作人物、蒙韦尔镇与拱心石钢铁公司均为虚构；历史事件、制度与时间线参照真实历史。")
                .font(Fonts.ui(11))
                .foregroundStyle(p.inkFaint)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                if !model.story.issues.isEmpty {
                    Text("剧本有 \(model.story.issues.count) 处问题").font(Fonts.ui(11)).foregroundStyle(p.accent)
                }
                Spacer()
                Text("v1.0").font(Fonts.typewriter(11)).foregroundStyle(p.inkFaint)
            }
        }
        .padding(.bottom, 12)
    }
}

struct TitleMenuItem: View {
    let title: String
    let detail: String?
    var badge = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            TitleMenuLabel(title: title, detail: detail, badge: badge)
        }
        .buttonStyle(PressAware())
    }
}

private struct TitleMenuLabel: View {
    let title: String
    let detail: String?
    let badge: Bool
    @Environment(\.palette) private var p
    @Environment(\.buttonPressed) private var pressed

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text(title)
                .font(Fonts.bodyBold(22))
                .foregroundStyle(pressed ? p.ink : p.ink.opacity(0.84))
                .fixedSize()
            if badge {
                Circle().fill(p.accent).frame(width: 7, height: 7)
                    .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 12 }
            }
            if let detail {
                Text(detail)
                    .font(Fonts.ui(12))
                    .foregroundStyle(p.inkFaint)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .offset(x: pressed ? 10 : 0)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(p.accent)
                .frame(width: pressed ? 18 : 0, height: 2)
                .offset(x: -22)
        }
        .padding(.vertical, 9)
        .contentShape(Rectangle())
        .animation(.easeOut(duration: 0.15), value: pressed)
    }
}
