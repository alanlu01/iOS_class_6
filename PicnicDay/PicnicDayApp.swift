import SwiftUI

@main
struct PicnicDayApp: App {
    var body: some Scene {
        WindowGroup {
            PicnicPlannerView()
                .environment(\.locale, Locale(identifier: "zh_Hant_TW"))
        }
    }
}
