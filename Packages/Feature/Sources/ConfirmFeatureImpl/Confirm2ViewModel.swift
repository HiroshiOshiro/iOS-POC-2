import Foundation
import ConfirmFeatureApi
import FactoryKit
import Domain
import Data

/// 確認画面2 の ViewModel。保存ボタンで UseCase を実行し、完了後は Router に遷移を依頼する。
/// フロー内の遷移（確認1 へ戻る）は `onBack` に委譲する。
@MainActor
final class Confirm2ViewModel: ObservableObject {
    let text: String
    @Published private(set) var isSubmitting = false

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
        Task { [weak self] in
            guard let self else { return }
            await self.submitUseCase.execute(text: self.text)
            self.isSubmitting = false
            self.router.navigateToComplete()
        }
    }

    func backButtonTapped() {
        onBack()
    }
}
