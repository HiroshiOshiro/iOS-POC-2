import Foundation

/// 確認画面1 の ViewModel。
/// フロー外への遷移（戻る）は Router、フロー内の遷移（次へ）は `onNext` に委譲する。
@MainActor
final class Confirm1ViewModel: ObservableObject {
    let text: String

    private let router: ConfirmFlowRouter
    private let onNext: () -> Void

    init(text: String, router: ConfirmFlowRouter, onNext: @escaping () -> Void) {
        self.text = text
        self.router = router
        self.onNext = onNext
    }

    func nextButtonTapped() {
        onNext()
    }

    func backButtonTapped() {
        router.navigateBack()
    }
}
