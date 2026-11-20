import SwiftUI

enum PicnicStyle {
    static let page = adaptive(0xF8F5EB, 0x1A1E16)
    static let surface = adaptive(0xFFFCF5, 0x242A20)
    static let control = adaptive(0xF2EFE3, 0x30372A)
    static let border = adaptive(0xE8E2D2, 0x384235)
    static let ink = adaptive(0x262D20, 0xF4F0E2)
    static let secondary = adaptive(0x5F6555, 0xBEC7B2)
    static let accent = adaptive(0x3C5737, 0xB8CE9F)
    static let button = Color(red: 0.23, green: 0.34, blue: 0.21)
    static let gold = Color(red: 0.97, green: 0.83, blue: 0.49)

    private static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}

struct PicnicPanel<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(PicnicStyle.accent)
                .accessibilityAddTraits(.isHeader)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PicnicStyle.surface, in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(PicnicStyle.border, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}
