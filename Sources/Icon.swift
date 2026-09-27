import AppKit
import SwiftUI

/// App 图标：钢厂夜空的橘红底，一只写着 NOT MINE 的鞋盒盒盖，上面搭着一块狗牌
struct IconArt: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 186, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x2A1C16), Color(hex: 0x120E0C)], startPoint: .top, endPoint: .bottom))
                .frame(width: 824, height: 824)
                .overlay(
                    RadialGradient(colors: [Color(hex: 0xC2561F, alpha: 0.75), .clear], center: .bottom, startRadius: 10, endRadius: 520)
                        .clipShape(RoundedRectangle(cornerRadius: 186, style: .continuous))
                        .frame(width: 824, height: 824)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 186, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 3)
                        .frame(width: 824, height: 824)
                )
                .shadow(color: .black.opacity(0.45), radius: 24, y: 14)

            ShoeboxLid(label: "NOT MINE")
                .frame(width: 330, height: 220)
                .scaleEffect(1.72)
                .rotationEffect(.degrees(-8))
                .position(x: 500, y: 450)

            // 珠链从狗牌的孔里垂出来，搭过盒盖的边
            Path { p in
                p.move(to: CGPoint(x: 560, y: 668))
                p.addQuadCurve(to: CGPoint(x: 300, y: 560), control: CGPoint(x: 420, y: 700))
            }
            .stroke(Color(hex: 0xC9C6BE), style: StrokeStyle(lineWidth: 10, lineCap: .round, dash: [0.5, 14]))

            DogTag()
                .frame(width: 300, height: 170)
                .rotationEffect(.degrees(14))
                .position(x: 690, y: 700)
        }
        .frame(width: 1024, height: 1024)
    }
}

/// 一块旧狗牌：圆角的不锈钢片、压出来的字、一截珠链
struct DogTag: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(LinearGradient(colors: [Color(hex: 0xDAD8D2), Color(hex: 0x9C9A94)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay(
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .stroke(Color(hex: 0x6E6C66), lineWidth: 4)
            )
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
            .shadow(color: .black.opacity(0.55), radius: 14, y: 8)
    }
}

enum IconRenderer {
    @MainActor
    static func render(to path: String) {
        let renderer = ImageRenderer(content: IconArt())
        renderer.scale = 1
        guard let cg = renderer.cgImage else {
            print("图标渲染失败")
            return
        }
        let rep = NSBitmapImageRep(cgImage: cg)
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
    }
}
