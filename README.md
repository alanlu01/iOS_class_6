# 野餐日和 · Picnic Day

規劃一場野餐，選擇集合時間、人數和預算，再把雨備日期、備註、色帶和封面整理成行程卡。「查看摘要」會檢查輸入，並用系統 Alert 顯示地點、日期、人數、總預算和準備事項。長按行程卡可複製完整行程。

開啟 `PicnicDay.xcodeproj`，選擇 `PicnicDay` scheme 和 iPhone 或 iPad 模擬器，按 **⌘R** 執行。App 最低支援 iOS／iPadOS 18，無第三方套件。修改 `project.yml` 後，可用 `xcodegen generate` 更新專案檔。

## 第 233 題使用的 SwiftUI 元件

| 區域 | 元件 | 功能 |
| --- | --- | --- |
| 行程 | `TextField`、`Picker`、`DatePicker` | 輸入野餐名稱，選擇地點與集合時間 |
| 人數與預算 | `Stepper`、`Slider` | 選擇參加人數和每人預算，立即更新總額 |
| 準備 | `Toggle`、`MultiDatePicker`、`TextEditor` | 決定是否帶野餐墊，選擇多個雨備日並記下備註 |
| 行程卡 | `PhotosPicker`、`ColorPicker`、`contextMenu` | 更換封面和色帶，長按卡片可複製行程或還原配色 |
| 查看摘要 | `.alert` | 顯示缺少名稱、集合時間已過等提示，或顯示目前的行程摘要 |

三個頁面共用同一份表單草稿。雨備日須晚於集合日，修改集合日後會移除已不適用的選擇。草稿保留到這次 App 執行結束。

## iPhone 17 模擬器畫面

[行程](docs/screenshots/iphone-schedule.png) · [人數與預算](docs/screenshots/iphone-budget.png) · [準備](docs/screenshots/iphone-preparation.png) · [摘要 Alert](docs/screenshots/iphone-alert.png) · [行程卡](docs/screenshots/iphone-card.png)

## 素材與題目

- 預設封面 `PicnicDay/Assets.xcassets/PicnicCover.imageset/picnic-cover.jpg` 使用 Codex 內建 ImageGen 生成。生成題材為午後公園草地上的奶油黃色格紋野餐墊、藤籃、橘子、檸檬水與三明治，採橫幅生活攝影構圖，左下留陰影供 App 疊放文字。
- [第 233 題 · 結合各種輸入元件與顯示 Alert 的 App](https://medium.com/彼得潘的試煉-勇者的-100-道-swift-ios-app-謎題/233-結合各種輸入元件-顯示-alert-的-swiftui-uikit-flutter-app-0b742250143d)

<details>
<summary>封面生成指令</summary>

> Use case: photorealistic-natural. Asset: wide 3:2 editorial cover photo for a Taiwanese picnic itinerary iPhone app. An inviting offline picnic in a quiet neighborhood park, on green grass in late afternoon. A cream and amber gingham blanket with a small woven picnic basket, two ripe oranges, a glass bottle of lemonade and a simply wrapped sandwich. Showing natural grass and soft shade at the edges, shallow warm sun, believable fresh food, tactile fabric, muted olive green and buttery tones, relaxed magazine food photography. Compose the primary items grouped just right of center within the middle half of image so the shot also crops gracefully to a wide horizontal banner. At lower left leave darker soft shaded grass as space for a white text overlay added by the app. No people, lettering, labels, logos, UI, frames or watermarks.

</details>
