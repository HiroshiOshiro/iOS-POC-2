import UIKit
import SwiftUI
import Domain
import Data

/// ObjC から確認フロー画面を生成するためのファクトリ。
/// `@import Feature;` して `UIViewController` として push する。
@MainActor
@objc public final class ConfirmFlowFactory: NSObject {

    /// 確認フロー（確認画面1→2）のビューコントローラを生成する。
    /// - Parameters:
    ///   - text: 入力画面で入力されたテキスト
    ///   - onCompleted: 保存完了時に呼ばれる（アプリ側で完了画面へ遷移する）
    ///   - onExit: 確認画面1で戻る操作をしたときに呼ばれる（アプリ側で入力画面へ戻す）
    @objc public static func makeConfirmFlow(
        text: String,
        onCompleted: @escaping () -> Void,
        onExit: @escaping () -> Void
    ) -> UIViewController {
        let useCase = SubmitTodoUseCaseImpl(repository: TodoRepositoryImpl())
        let root = ConfirmFlowView(
            text: text,
            submitUseCase: useCase,
            onCompleted: onCompleted,
            onExit: onExit
        )
        return UIHostingController(rootView: root)
    }
}
