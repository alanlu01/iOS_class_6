import ImageIO
import PhotosUI
import SwiftUI

enum PicnicField: Hashable {
    case title
    case notes
}

struct PicnicPlannerView: View {
    private enum Page: String, CaseIterable, Identifiable {
        case schedule = "行程"
        case preparation = "準備"
        case card = "行程卡"

        var id: Self { self }
    }

    private enum Notice {
        case missingTitle
        case pastDate
        case invalidPhoto
        case summary(PicnicPlan)

        var title: String {
            switch self {
            case .missingTitle: "請輸入野餐名稱"
            case .pastDate: "請調整野餐時間"
            case .invalidPhoto: "無法讀取照片"
            case .summary: "野餐行程摘要"
            }
        }

        var message: String {
            switch self {
            case .missingTitle: "為這次野餐取個名字，再查看行程摘要。"
            case .pastDate: "請選擇目前時間之後的集合時間。"
            case .invalidPhoto: "請重新選擇一張可讀取的照片。"
            case let .summary(plan): plan.summary
            }
        }
    }

    @State private var plan = PicnicPlan()
    @State private var page = Page.schedule
    @State private var accent = PicnicStyle.gold
    @State private var cover: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false
    @State private var showsBackupCalendar = false
    @State private var notice: Notice?
    @FocusState private var focusedField: PicnicField?
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                pageContent
                    .frame(maxWidth: 560)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 22)
                    .frame(maxWidth: .infinity)
            }
            .id(page)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(PicnicStyle.page.ignoresSafeArea())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            footer
        }
        .tint(PicnicStyle.accent)
        .foregroundStyle(PicnicStyle.ink)
        .onChange(of: plan.start) {
            plan.removeUnavailableBackupDays()
        }
        .task(id: photoItem) {
            await loadCover(photoItem)
        }
        .alert(notice?.title ?? "", isPresented: Binding(
            get: { notice != nil },
            set: { if !$0 { notice = nil } }
        ), presenting: notice) { presentedNotice in
            switch presentedNotice {
            case .summary:
                Button("查看行程卡") { page = .card }
                Button("繼續編輯", role: .cancel) {}
            case .missingTitle:
                Button("輸入名稱") {
                    page = .schedule
                    focusedField = .title
                }
            case .pastDate:
                Button("返回行程") { page = .schedule }
            case .invalidPhoto:
                Button("好", role: .cancel) {}
            }
        } message: { presentedNotice in
            Text(presentedNotice.message)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 11) {
                Image(systemName: "basket.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(PicnicStyle.button)
                    .frame(width: 42, height: 42)
                    .background(PicnicStyle.gold, in: .circle)
                    .accessibilityHidden(true)

                Text("野餐日和")
                    .font(.system(.title2, design: .serif, weight: .heavy))
                    .accessibilityAddTraits(.isHeader)
            }

            Picker("編輯區域", selection: Binding(
                get: { page },
                set: {
                    focusedField = nil
                    page = $0
                }
            )) {
                ForEach(Page.allCases) { page in
                    Text(page.rawValue).tag(page)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("picnic-page-picker")
        }
        .frame(maxWidth: 560)
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 9)
        .frame(maxWidth: .infinity)
        .background(PicnicStyle.page)
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .schedule:
            PicnicSchedulePage(plan: $plan, focus: $focusedField, cover: cover, accent: accent)
        case .preparation:
            PicnicPreparationPage(plan: $plan, focus: $focusedField, showsCalendar: $showsBackupCalendar)
        case .card:
            PicnicCardPage(plan: plan, cover: cover, accent: $accent, photoItem: $photoItem,
                           isLoadingPhoto: isLoadingPhoto, restoreCover: restoreCover)
        }
    }

    private var footer: some View {
        Group {
            if focusedField != nil {
                primaryButton("完成編輯", icon: "keyboard.chevron.compact.down") {
                    focusedField = nil
                }
            } else {
                let layout = typeSize.isAccessibilitySize
                    ? AnyLayout(VStackLayout(alignment: .leading, spacing: 10))
                    : AnyLayout(HStackLayout(spacing: 16))

                layout {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("預估總額")
                            .font(.caption)
                            .foregroundStyle(PicnicStyle.secondary)
                        Text(PicnicPlan.money(plan.totalBudget))
                            .font(.title3.bold().monospacedDigit())
                            .accessibilityIdentifier("picnic-total")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    primaryButton("查看摘要", icon: "arrow.right") {
                        showSummary()
                    }
                    .accessibilityIdentifier("picnic-show-summary")
                }
            }
        }
        .frame(maxWidth: 560)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(PicnicStyle.surface.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(PicnicStyle.border)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    private func primaryButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                Image(systemName: icon)
                    .accessibilityHidden(true)
            }
            .font(.headline)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .frame(minHeight: 48)
            .foregroundStyle(.white)
            .background(PicnicStyle.button, in: .rect(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }

    private func showSummary() {
        if plan.trimmedTitle.isEmpty {
            notice = .missingTitle
        } else if plan.start <= .now {
            notice = .pastDate
        } else {
            notice = .summary(plan)
        }
    }

    private func restoreCover() {
        photoItem = nil
        cover = nil
        isLoadingPhoto = false
    }

    @MainActor
    private func loadCover(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        isLoadingPhoto = true
        defer {
            if item == photoItem {
                isLoadingPhoto = false
                photoItem = nil
            }
        }

        do {
            let data = try await item.loadTransferable(type: Data.self)
            guard !Task.isCancelled, item == photoItem else { return }

            let options: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 1_440
            ]
            guard let data,
                  let source = CGImageSourceCreateWithData(data as CFData, nil),
                  let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                notice = .invalidPhoto
                return
            }

            cover = UIImage(cgImage: thumbnail)
        } catch {
            if !Task.isCancelled, item == photoItem {
                notice = .invalidPhoto
            }
        }
    }
}

#Preview {
    PicnicPlannerView()
        .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
}
