// iOS 图标渲染：在 Mac 上跑，输出 1024×1024、不带透明通道的 PNG
// 用法：swiftc -parse-as-library -O render-icon.swift -o render-icon && ./render-icon <输出.png>
//
// 画面和 Mac 版图标（Sources/Icon.swift）是同一张：钢厂夜空的橘红底，一只写着 NOT MINE 的鞋盒盒盖，
// 搭着柯蒂斯的狗牌。区别是 iOS 的圆角由系统来切，图标本身要铺满整个方块——
// 所以去掉 Mac 版那块带阴影的圆角底板，内容整体放大 1.18 倍，让盒盖和狗牌在手机桌面上占到差不多的比例。
// 本文件单独编译，不依赖 Sources/：盒盖、狗牌、颗粒各抄了一份简化版。
import ImageIO
import SwiftUI
import UniformTypeIdentifiers

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: alpha)
    }
}

/// 纸板颗粒：一张固定种子的灰度噪点图，平铺后以 overlay 混合
enum Grain {
    static let image: CGImage? = {
        let side = 160
        var state: UInt64 = 1950
        var pixels = [UInt8](repeating: 255, count: side * side * 4)
        for i in 0..<(side * side) {
            state = state &* 6364136223846793005 &+ 1442695040888963407
            let v = UInt8(truncatingIfNeeded: state >> 56)
            pixels[i * 4] = v
            pixels[i * 4 + 1] = v
            pixels[i * 4 + 2] = v
        }
        guard let provider = CGDataProvider(data: Data(pixels) as CFData) else { return nil }
        return CGImage(width: side, height: side, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: side * 4,
                       space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }()
}

struct Lid: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(LinearGradient(colors: [Color(hex: 0xC9A574), Color(hex: 0xA9824F)], startPoint: .topLeading, endPoint: .bottomTrailing))
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(hex: 0x7A5A33, alpha: 0.55), lineWidth: 2)
                .padding(10)
            if let grain = Grain.image {
                Image(decorative: grain, scale: 1)
                    .resizable(resizingMode: .tile)
                    .blendMode(.overlay)
                    .opacity(0.18)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Thom McAn")
                    .font(.custom("Bradley Hand", size: 15).weight(.bold))
                    .foregroundStyle(Color(hex: 0x7E2A1C, alpha: 0.7))
                Text("SIZE 10½  ·  BLACK OXFORD")
                    .font(.custom("American Typewriter", size: 8))
                    .tracking(1)
                    .foregroundStyle(Color(hex: 0x4A3520, alpha: 0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 22)
            .padding(.leading, 26)
            Text("NOT MINE")
                .font(.custom("Marker Felt", size: 52))
                .foregroundStyle(Color(hex: 0x1E1B18, alpha: 0.9))
                .rotationEffect(.degrees(-3))
                .offset(y: 16)
            Rectangle()
                .fill(Color(hex: 0xF3EBD2, alpha: 0.35))
                .frame(width: 110, height: 24)
                .rotationEffect(.degrees(12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 20, y: -6)
        }
        .frame(width: 330, height: 220)
        .shadow(color: .black.opacity(0.55), radius: 22, y: 12)
    }
}

struct Tag: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(LinearGradient(colors: [Color(hex: 0xDAD8D2), Color(hex: 0x9C9A94)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(RoundedRectangle(cornerRadius: 34, style: .continuous).stroke(Color(hex: 0x6E6C66), lineWidth: 4))
            .overlay(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("BELL").font(.custom("Courier New", size: 40).weight(.bold))
                    Text("CURTIS L").font(.custom("Courier New", size: 34).weight(.bold))
                    Text("O POS").font(.custom("Courier New", size: 28).weight(.bold))
                }
                .foregroundStyle(Color(hex: 0x3A3834))
                .padding(.leading, 52)
            }
            .overlay(alignment: .leading) {
                Circle().stroke(Color(hex: 0x6E6C66), lineWidth: 4).frame(width: 22, height: 22).padding(.leading, 16)
            }
            .frame(width: 300, height: 170)
            .shadow(color: .black.opacity(0.55), radius: 14, y: 8)
    }
}

struct IOSIconArt: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x2A1C16), Color(hex: 0x120E0C)], startPoint: .top, endPoint: .bottom)
            RadialGradient(colors: [Color(hex: 0xC2561F, alpha: 0.75), .clear], center: .bottom, startRadius: 10, endRadius: 640)

            // 下面三样的坐标和 Mac 版 IconArt 一致（1024 画布），整体放大后居中
            ZStack {
                Lid()
                    .scaleEffect(1.72)
                    .rotationEffect(.degrees(-8))
                    .position(x: 500, y: 450)
                // 珠链从狗牌的孔里垂出来，搭过盒盖的边
                Path { p in
                    p.move(to: CGPoint(x: 560, y: 668))
                    p.addQuadCurve(to: CGPoint(x: 300, y: 560), control: CGPoint(x: 420, y: 700))
                }
                .stroke(Color(hex: 0xC9C6BE), style: StrokeStyle(lineWidth: 10, lineCap: .round, dash: [0.5, 14]))
                Tag()
                    .rotationEffect(.degrees(14))
                    .position(x: 690, y: 700)
            }
            .frame(width: 1024, height: 1024)
            .scaleEffect(1.18)
            .offset(y: -6)
        }
        .frame(width: 1024, height: 1024)
    }
}

@main
enum RenderIcon {
    @MainActor
    static func main() {
        let out = CommandLine.arguments.dropFirst().first ?? "icon-1024.png"
        let renderer = ImageRenderer(content: IOSIconArt())
        renderer.scale = 1
        renderer.isOpaque = true
        guard let rendered = renderer.cgImage,
              let ctx = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
            print("图标渲染失败")
            exit(1)
        }
        // 重画进一张没有 alpha 通道的位图：iOS 图标不允许透明
        ctx.draw(rendered, in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
        guard let flat = ctx.makeImage(),
              let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: out) as CFURL, UTType.png.identifier as CFString, 1, nil) else {
            print("写不了 \(out)")
            exit(1)
        }
        CGImageDestinationAddImage(dest, flat, nil)
        exit(CGImageDestinationFinalize(dest) ? 0 : 1)
    }
}
