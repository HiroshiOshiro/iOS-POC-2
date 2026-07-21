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
    /// 発生中のエラー（`LocalizedError`）。View は `.alert` でこれを提示する。
    @Published private(set) var error: ConfirmError?

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
        error = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.submitUseCase.execute(text: self.text)
                self.isSubmitting = false
                // 成功時のみ完了画面へ進む。
                self.router.navigateToComplete()
            } catch {
                // 失敗時は画面に留まりエラーを提示する（送信元のエラー種別は問わずまとめる）。
                self.isSubmitting = false
                self.error = .submitFailed
            }
        }
    }

    func backButtonTapped() {
        onBack()
    }

    /// アラートを閉じたときにエラー状態を解除する。
    func dismissError() {
        error = nil
    }
}
