import SwiftUI

/// 两套配色：夜（默认，钢厂夜里的天是橘红色的）和相纸（老照片的米白）。
/// 所有视图都从环境里取 palette，不写死颜色。
struct Palette {
    var bg: Color
    var panel: Color
    var panelHi: Color
    var ink: Color
    var inkDim: Color
    var inkFaint: Color
    var line: Color
    var accent: Color      // 钢水的橘红
    var khaki: Color       // 次要色：柯达胶卷那种褪了色的青
    var gold: Color
    var paper: Color
    var paperInk: Color
    var stamp: Color       // 记号笔的红
    var isDark: Bool

    static let night = Palette(
        bg: Color(hex: 0x131210), panel: Color(hex: 0x1B1A17), panelHi: Color(hex: 0x27241F),
        ink: Color(hex: 0xE9E1CF), inkDim: Color(hex: 0xA9A08D), inkFaint: Color(hex: 0x6F695C),
        line: Color(hex: 0x35312A), accent: Color(hex: 0xD06A2C), khaki: Color(hex: 0x76A39C),
        gold: Color(hex: 0xD9B45E), paper: Color(hex: 0xEEE5CE), paperInk: Color(hex: 0x2A241C),
        stamp: Color(hex: 0xB3362B), isDark: true
    )

    static let photo = Palette(
        bg: Color(hex: 0xEEE6D4), panel: Color(hex: 0xE4DAC4), panelHi: Color(hex: 0xD8CCB2),
        ink: Color(hex: 0x231E17), inkDim: Color(hex: 0x5C5446), inkFaint: Color(hex: 0x8A8070),
        line: Color(hex: 0xC2B69C), accent: Color(hex: 0xB5531E), khaki: Color(hex: 0x3F6F69),
        gold: Color(hex: 0x8E6A1F), paper: Color(hex: 0xF6F0E1), paperInk: Color(hex: 0x2A241C),
        stamp: Color(hex: 0xA8301F), isDark: false
    )

    func tier(_ t: String) -> Color {
        switch t {
        case "TE": return gold
        case "GE": return Color(hex: isDark ? 0x86A860 : 0x4E6E30)
        case "NE": return Color(hex: isDark ? 0x9C9582 : 0x6B6453)
        case "SE": return Color(hex: isDark ? 0x7196AE : 0x3F6378)
        default: return Color(hex: isDark ? 0xC0503A : 0x8E2B24)
        }
    }

    static func tierName(_ t: String) -> String {
        switch t {
        case "TE": return "真结局"
        case "GE": return "好结局"
        case "NE": return "普通结局"
        case "SE": return "特殊结局"
        default: return "坏结局"
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.night
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}

/// 正文宋体，信件和公文仿宋，界面小字苹方，英文标牌打字机体，鞋盒上的字是记号笔
enum Fonts {
    static func body(_ size: CGFloat) -> Font { .custom("Songti SC", size: size) }
    static func bodyBold(_ size: CGFloat) -> Font { .custom("Songti SC", size: size).weight(.bold) }
    static func display(_ size: CGFloat) -> Font { .custom("Songti SC", size: size).weight(.black) }
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font { .custom("PingFang SC", size: size).weight(weight) }
    static func doc(_ size: CGFloat) -> Font { .custom("STFangsong", size: size) }
    static func typewriter(_ size: CGFloat) -> Font { .custom("American Typewriter", size: size) }
    static func mono(_ size: CGFloat) -> Font { .custom("Courier New", size: size) }
    static func marker(_ size: CGFloat) -> Font { .custom("Marker Felt", size: size) }
    static func hand(_ size: CGFloat) -> Font { .custom("Noteworthy", size: size) }
}

enum Prefs {
    static let textMode = "textMode"     // 0 逐段浮现  1 打字机  2 立即显示
    static let fontSize = "fontSize"
    static let theme = "theme"           // 0 夜  1 相纸
    static let motion = "motion"
    static let hints = "hints"
    static let sidebar = "sidebar"
}
