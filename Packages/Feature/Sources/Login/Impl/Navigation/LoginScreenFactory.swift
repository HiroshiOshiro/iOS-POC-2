import UIKit
import SwiftUI

/// ログイン画面をアプリ（ObjC）へ公開する窓口。
/// タブに載せるため ObjC から生成できるよう `@objc` にし、返すのは `UIViewController` だけ。
/// 依存（UseCase 等）は DI コンテナから解決される。
/// NiA 相当: feature:*:impl の navigation の EntryProvider（`InterestsEntryProvider`）。
@MainActor
@objc public final class LoginScreenFactory: NSObject {

    @objc public static func makeLoginScreen() -> UIViewController {
        UIHostingController(rootView: LoginView())
    }
}
