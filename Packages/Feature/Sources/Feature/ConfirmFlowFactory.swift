import UIKit
import SwiftUI
import Domain
import Data

/// Feature の外へ公開する唯一の窓口。
/// SwiftUI の View（struct）・ViewModel・UIHostingController（ジェネリック）は Feature 内に閉じ込め、
/// 外へは `UIViewController` という共通の型だけを返す。
public enum ConfirmFlowFactory {

    /// 確認フロー（確認画面1→2）のビューコントローラを生成する。
    /// - Parameters:
    ///   - text: 入力画面で入力されたテキスト
    ///   - router: フロー外への遷移（完了画面へ / 入力へ戻る）を担うアプリ側の実装
    @MainActor
    public static func makeConfirmFlow(text: String, router: ConfirmFlowRouter) -> UIViewController {
        let useCase = SubmitTodoUseCaseImpl(repository: TodoRepositoryImpl())
        let root = ConfirmFlowView(text: text, submitUseCase: useCase, router: router)
        return UIHostingController(rootView: root)
    }
}
