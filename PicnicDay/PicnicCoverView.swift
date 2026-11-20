import SwiftUI

struct PicnicCoverView: View {
    let plan: PicnicPlan
    let cover: UIImage?
    let accent: Color

    private var image: Image {
        cover.map { Image(uiImage: $0) } ?? Image("PicnicCover")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(plan.displayTitle)
                .font(.system(.largeTitle, design: .serif, weight: .heavy))
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("picnic-cover-title")

            Label(plan.venue.rawValue, systemImage: "mappin")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 176, alignment: .bottomLeading)
        .background {
            GeometryReader { proxy in
                ZStack {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()

                    LinearGradient(colors: [.black.opacity(0.05), .black.opacity(0.78)],
                                   startPoint: .top, endPoint: .bottom)
                }
            }
            .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(accent)
                .frame(height: 5)
                .accessibilityHidden(true)
        }
        .background {
            Color.black
        }
        .clipShape(.rect(cornerRadius: 20))
    }
}
