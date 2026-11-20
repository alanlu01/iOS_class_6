import Foundation

struct PicnicPlan {
    enum Venue: String, CaseIterable, Identifiable {
        case daan = "大安森林公園"
        case dajia = "大佳河濱公園"
        case huashan = "華山大草原"

        var id: Self { self }
    }

    static let capacity = 1...12
    static let budgets = 100.0...1_000.0
    static let locale = Locale(identifier: "zh_Hant_TW")

    var title = ""
    var venue = Venue.daan
    var start: Date = {
        let calendar = Calendar.current
        let now = Date.now
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        return calendar.date(bySettingHour: 14, minute: 0, second: 0, of: tomorrow) ?? tomorrow
    }()
    var guests = 4
    var budgetPerGuest = 250.0
    var bringBlanket = true
    var notes = ""
    var backupDays: Set<DateComponents> = []

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    var displayTitle: String { trimmedTitle.isEmpty ? "我的野餐" : trimmedTitle }
    var trimmedNotes: String { notes.trimmingCharacters(in: .whitespacesAndNewlines) }
    var totalBudget: Int { guests * Int(budgetPerGuest) }
    var blanketText: String { bringBlanket ? "攜帶野餐墊" : "無須攜帶野餐墊" }

    var firstBackupDay: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: start)) ?? start
    }

    var backupDates: [Date] {
        backupDays.compactMap { Calendar.current.date(from: $0) }
            .filter { $0 >= firstBackupDay }
            .sorted()
    }

    var dateText: String {
        start.formatted(.dateTime.year().month().day().weekday().hour().minute().locale(Self.locale))
    }

    var summary: String {
        """
        \(displayTitle) · \(venue.rawValue)
        \(dateText) · \(guests) 人
        每人 \(Self.money(Int(budgetPerGuest)))，合計 \(Self.money(totalBudget))
        \(blanketText) · 雨備 \(backupDates.count) 天
        """
    }

    var clipboardSummary: String {
        let dates = backupDates.map(Self.backupDateText).joined(separator: "、")
        var sections = [summary]
        if !dates.isEmpty { sections.append("雨備日期\n\(dates)") }
        if !trimmedNotes.isEmpty { sections.append("備註\n\(trimmedNotes)") }
        return sections.joined(separator: "\n\n")
    }

    mutating func removeUnavailableBackupDays() {
        let minimum = firstBackupDay
        backupDays = backupDays.filter { components in
            guard let date = Calendar.current.date(from: components) else { return false }
            return date >= minimum
        }
    }

    static func backupDateText(_ date: Date) -> String {
        date.formatted(.dateTime.year().month().day().locale(locale))
    }

    static func money(_ amount: Int) -> String {
        "NT$\(amount.formatted(.number.locale(locale)))"
    }
}
