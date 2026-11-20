import PhotosUI
import SwiftUI

struct PicnicSchedulePage: View {
    @Binding var plan: PicnicPlan
    var focus: FocusState<PicnicField?>.Binding
    let cover: UIImage?
    let accent: Color

    var body: some View {
        VStack(spacing: 14) {
            PicnicCoverView(plan: plan, cover: cover, accent: accent)
                .contentShape(.contextMenuPreview, .rect(cornerRadius: 20))

            PicnicPanel(title: "基本資料", icon: "pencil.line") {
                VStack(alignment: .leading, spacing: 7) {
                    Text("野餐名稱")
                        .font(.subheadline.weight(.medium))
                        .accessibilityHidden(true)

                    TextField("週末橘子野餐", text: $plan.title)
                        .padding(12)
                        .background(PicnicStyle.control, in: .rect(cornerRadius: 10))
                        .focused(focus, equals: .title)
                        .submitLabel(.done)
                        .onSubmit { focus.wrappedValue = nil }
                        .accessibilityLabel("野餐名稱")
                        .accessibilityIdentifier("picnic-title")
                }

                Divider()

                HStack {
                    Text("野餐地點")
                        .accessibilityHidden(true)
                    Spacer(minLength: 8)
                    Picker("野餐地點", selection: $plan.venue) {
                        ForEach(PicnicPlan.Venue.allCases) { venue in
                            Text(venue.rawValue).tag(venue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("picnic-venue")
                }

                Divider()

                VStack(alignment: .leading, spacing: 7) {
                    Text("集合時間")
                        .accessibilityHidden(true)
                    DatePicker("集合時間", selection: $plan.start,
                               in: Calendar.current.startOfDay(for: .now)...)
                        .labelsHidden()
                        .accessibilityIdentifier("picnic-start")
                }
            }

            PicnicPanel(title: "人數與預算", icon: "person.2") {
                Stepper(value: $plan.guests, in: PicnicPlan.capacity) {
                    HStack {
                        Text("參加人數")
                        Spacer()
                        Text("\(plan.guests) 人")
                            .font(.body.weight(.semibold).monospacedDigit())
                            .accessibilityIdentifier("picnic-guests")
                    }
                }
                .accessibilityIdentifier("picnic-guest-stepper")

                Divider()

                LabeledContent("每人預算") {
                    Text(PicnicPlan.money(Int(plan.budgetPerGuest)))
                        .font(.body.weight(.semibold).monospacedDigit())
                        .foregroundStyle(PicnicStyle.ink)
                }

                Slider(value: $plan.budgetPerGuest, in: PicnicPlan.budgets, step: 50)
                    .accessibilityLabel("每人預算")
                    .accessibilityValue(PicnicPlan.money(Int(plan.budgetPerGuest)))
                    .accessibilityIdentifier("picnic-budget")
            }
        }
    }
}

struct PicnicPreparationPage: View {
    @Binding var plan: PicnicPlan
    var focus: FocusState<PicnicField?>.Binding
    @Binding var showsCalendar: Bool

    var body: some View {
        VStack(spacing: 14) {
            PicnicPanel(title: "野餐用品", icon: "basket") {
                Toggle("攜帶野餐墊", isOn: $plan.bringBlanket)
                    .accessibilityIdentifier("picnic-blanket")
            }

            PicnicPanel(title: "雨備日期", icon: "cloud.rain") {
                DisclosureGroup(isExpanded: $showsCalendar) {
                    MultiDatePicker("選擇雨備日期", selection: $plan.backupDays, in: plan.firstBackupDay...)
                        .datePickerStyle(.graphical)
                        .padding(.top, 10)
                        .accessibilityIdentifier("picnic-backup-calendar")
                } label: {
                    LabeledContent("選擇日期", value: "已選 \(plan.backupDates.count) 天")
                }
                .accessibilityIdentifier("picnic-backup-disclosure")

                if !plan.backupDates.isEmpty {
                    Text(plan.backupDates.map(PicnicPlan.backupDateText).joined(separator: "、"))
                        .font(.subheadline)
                        .foregroundStyle(PicnicStyle.secondary)
                }
            }

            PicnicPanel(title: "備註", icon: "text.alignleft") {
                ZStack(alignment: .topLeading) {
                    if plan.notes.isEmpty {
                        Text("集合地點或餐點過敏提醒")
                            .foregroundStyle(PicnicStyle.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }

                    TextEditor(text: $plan.notes)
                        .frame(minHeight: 94)
                        .padding(5)
                        .scrollContentBackground(.hidden)
                        .focused(focus, equals: .notes)
                        .accessibilityLabel("野餐備註")
                        .accessibilityIdentifier("picnic-notes")
                }
                .background(PicnicStyle.control, in: .rect(cornerRadius: 10))
            }
        }
    }
}

struct PicnicCardPage: View {
    let plan: PicnicPlan
    let cover: UIImage?
    @Binding var accent: Color
    @Binding var photoItem: PhotosPickerItem?
    let isLoadingPhoto: Bool
    let restoreCover: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            PicnicCoverView(plan: plan, cover: cover, accent: accent)
                .contextMenu {
                    Button("複製行程摘要", systemImage: "doc.on.doc") {
                        UIPasteboard.general.string = plan.clipboardSummary
                    }
                    Button("還原卡片配色", systemImage: "arrow.counterclockwise") {
                        accent = PicnicStyle.gold
                    }
                }

            PicnicPanel(title: "行程明細", icon: "list.bullet.rectangle") {
                Label(plan.dateText, systemImage: "calendar")
                Label("\(plan.guests) 人 · \(PicnicPlan.money(Int(plan.budgetPerGuest)))／人", systemImage: "person.2")
                Label(plan.blanketText, systemImage: "basket")
                    .accessibilityIdentifier("picnic-blanket-summary")

                if !plan.backupDates.isEmpty {
                    Label(plan.backupDates.map(PicnicPlan.backupDateText).joined(separator: "、"),
                          systemImage: "cloud.rain")
                }

                if !plan.trimmedNotes.isEmpty {
                    Divider()
                    Text(plan.trimmedNotes)
                        .foregroundStyle(PicnicStyle.secondary)
                        .accessibilityIdentifier("picnic-notes-summary")
                }
            }

            PicnicPanel(title: "卡片外觀", icon: "paintpalette") {
                ColorPicker("卡片色帶", selection: $accent, supportsOpacity: false)

                Divider()

                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label(cover == nil ? "選擇封面照片" : "更換封面照片", systemImage: "photo")
                        .frame(minHeight: 36)
                }
                .accessibilityIdentifier("picnic-photo-picker")

                if isLoadingPhoto {
                    ProgressView("載入照片中")
                        .font(.subheadline)
                }

                if cover != nil {
                    Button("恢復預設封面", action: restoreCover)
                        .font(.subheadline)
                        .frame(minHeight: 36)
                        .accessibilityIdentifier("picnic-restore-cover")
                }
            }
        }
    }
}
