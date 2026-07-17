import UIKit
import SwiftUI
import Domain
import Data

/// ログイン画面をアプリ（ObjC）へ公開する窓口。
/// タブに載せるため ObjC から生成できるよう `@objc` にし、返すのは `UIViewController` だけ。
@MainActor
@objc public final class LoginScreenFactory: NSObject {

    @objc public static func makeLoginScreen() -> UIViewController {
        let repository = AuthRepositoryImpl()
        let view = LoginView(
            loginUseCase: LoginUseCaseImpl(repository: repository),
            loadSessionUseCase: LoadSessionUseCaseImpl(repository: repository)
        )
        return UIHostingController(rootView: view)
    }
}
