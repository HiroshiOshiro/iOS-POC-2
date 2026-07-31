import UIKit
import SwiftUI

/// 【デモ】app-target の Swift から、ObjC と同じ main バンドルの String Catalog
/// （`iOS-POC-2/Localizable.xcstrings`）を `String(localized:)` で引けることを示す画面。
///
/// `bundle:` を指定しない → 既定で `Bundle.main` を参照するため、ObjC の
/// `NSLocalizedString(@"common.ok", nil)` と **同じキー・同じ実体** を共有する。
/// （Feature モジュールは `bundle: .module` を見るので、この共有は app-target 限定の話。）
///
/// この画面は本番機能ではなく、共有できることを可視化するためのデモ。
struct LocalizationSharingDemoView: View {

    /// ObjC も使っている main バンドルのキー。app-target Swift から `String(localized:)` で解決する。
    private let rows: [(key: String, value: String)] = [
        ("tab.todo", String(localized: "tab.todo")),
        ("common.ok", String(localized: "common.ok")),
        ("todo.input.title", String(localized: "todo.input.title")),
        ("todo.input.save", String(localized: "todo.input.save")),
        ("completion.title", String(localized: "completion.title"))
    ]

    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(verbatim: """
                    これは動作確認用のデモ画面です（本番機能ではありません）。

                    この画面は app-target の Swift で、ObjC と同じ main バンドルの \
                    String Catalog を String(localized:)（bundle 指定なし＝.main）で \
                    引いています。ObjC の NSLocalizedString(@"…", nil) と同じキー・同じ実体です。
                    """)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                }

                Section(header: Text(verbatim: "ObjC と共有しているキー → 値（Swift が解決）")) {
                    ForEach(rows, id: \.key) { row in
                        HStack {
                            Text(verbatim: row.key)
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Text(verbatim: row.value)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            .navigationTitle("🧪 ローカライズ共有デモ")
        }
    }
}

/// 【デモ】ローカライズ共有デモ画面を ObjC（タブ）へ公開する窓口。
/// タブに載せるため ObjC から生成できるよう `@objc`。返すのは `UIViewController` だけ。
@MainActor
@objc final class LocalizationDemoScreenFactory: NSObject {
    @objc static func makeDemoScreen() -> UIViewController {
        UIHostingController(rootView: LocalizationSharingDemoView())
    }
}
