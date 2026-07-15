import SwiftUI
import Domain

/// 確認フロー内の遷移状態。
@MainActor
final class ConfirmRouter: ObservableObject {
    enum Step {
        case confirm1
        case confirm2
    }
    @Published var step: Step = .confirm1
}

/// 確認画面1→2 を内包するフロー。iOS 15 対応のため NavigationStack は使わず、
/// 独自バー＋状態遷移で push/pop 相当を表現する。
struct ConfirmFlowView: View {
    private let text: String
    private let submitUseCase: any SubmitTodoUseCase
    private let onCompleted: () -> Void
    private let onExit: () -> Void

    @StateObject private var router = ConfirmRouter()

    init(
        text: String,
        submitUseCase: any SubmitTodoUseCase,
        onCompleted: @escaping () -> Void,
        onExit: @escaping () -> Void
    ) {
        self.text = text
        self.submitUseCase = submitUseCase
        self.onCompleted = onCompleted
        self.onExit = onExit
    }

    var body: some View {
        ZStack {
            switch router.step {
            case .confirm1:
                Confirm1View(
                    text: text,
                    onNext: { router.step = .confirm2 },
                    onBack: onExit
                )
                .transition(.move(edge: .leading))
            case .confirm2:
                Confirm2View(
                    text: text,
                    submitUseCase: submitUseCase,
                    onCompleted: onCompleted,
                    onBack: { router.step = .confirm1 }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: router.step)
    }
}

/// プレビュー用の何もしない UseCase スタブ。
private struct PreviewSubmitTodoUseCase: SubmitTodoUseCase {
    func execute(text: String) async {}
}

#Preview {
    ConfirmFlowView(
        text: "牛乳を買う",
        submitUseCase: PreviewSubmitTodoUseCase(),
        onCompleted: {},
        onExit: {}
    )
}
