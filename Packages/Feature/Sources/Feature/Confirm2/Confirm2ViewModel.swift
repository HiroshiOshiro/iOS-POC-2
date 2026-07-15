import Foundation
import Domain

/// 確認画面2 の ViewModel。保存ボタンで UseCase を実行する。
@MainActor
final class Confirm2ViewModel: ObservableObject {
    let text: String
    @Published private(set) var isSubmitting = false

    private let submitUseCase: any SubmitTodoUseCase
    private let onCompleted: () -> Void

    init(
        text: String,
        submitUseCase: any SubmitTodoUseCase,
        onCompleted: @escaping () -> Void
    ) {
        self.text = text
        self.submitUseCase = submitUseCase
        self.onCompleted = onCompleted
    }

    func save() {
        guard !isSubmitting else { return }
        isSubmitting = true
        Task { [weak self] in
            guard let self else { return }
            await self.submitUseCase.execute(text: self.text)
            self.isSubmitting = false
            self.onCompleted()
        }
    }
}
