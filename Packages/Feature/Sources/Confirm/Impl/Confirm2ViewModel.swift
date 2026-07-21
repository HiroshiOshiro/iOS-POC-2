import Foundation
import ConfirmApi
import FactoryKit
import Domain
import Data

/// 確認画面2 の ViewModel。保存ボタンで UseCase を実行し、完了後は Router に遷移を依頼する。
/// フロー内の遷移（確認1 へ戻る）は `onBack` に委譲する。
/// NiA 相当: feature:*:impl の ViewModel（`TopicViewModel`）。
@MainActor
final class Confirm2ViewModel: ObservableObject {
    let text: String
    @Published private(set) var isSubmitting = false
    @Published private(set) var errorMessage: String?

    @Injected(\.submitTodoUseCase) private var submitUseCase

    private let router: ConfirmFlowRouter
    private let onBack: () -> Void

    init(text: String, router: ConfirmFlowRouter, onBack: @escaping () -> Void) {
        self.text = text
        self.router = router
        self.onBack = onBack
    }

    func saveButtonTapped() {
        guard !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.submitUseCase.execute(text: self.text)
                self.isSubmitting = false
                // 成功時のみ完了画面へ進む。
                self.router.navigateToComplete()
            } catch {
                // 失敗時は画面に留まりエラーを表示する（送信元のエラー種別は問わずメッセージ化）。
                self.isSubmitting = false
                self.errorMessage = L("confirm2.error")
            }
        }
    }

    func backButtonTapped() {
        onBack()
    }
}
