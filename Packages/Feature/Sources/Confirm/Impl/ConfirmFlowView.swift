import SwiftUI
import ConfirmApi
import FactoryKit
import Domain
import Data

/// 確認フロー内部の遷移状態（Feature 内で完結する 確認1↔確認2 の切り替え）。
/// フロー外への遷移は `ConfirmFlowRouter` が担う。
@MainActor
final class ConfirmFlowState: ObservableObject {
    enum Step {
        case confirm1
        case confirm2
    }
    @Published var step: Step = .confirm1
}

/// 確認画面1→2 を内包するフロー。iOS 15 対応のため NavigationStack は使わず、
/// 独自バー＋状態遷移で push/pop 相当を表現する。
/// NiA 相当なし: 確認1↔2 を束ねる feature 内のローカルなナビゲーションホスト。
/// NiA は遷移を app の NavHost + 各画面の NavKey で表すため、この容器に対応物はない。
/// （中の `Confirm1View` / `Confirm2View` が NiA の `*Screen` に相当する。）
struct ConfirmFlowView: View {
    private let text: String
    private let router: ConfirmFlowRouter

    @StateObject private var state = ConfirmFlowState()

    init(text: String, router: ConfirmFlowRouter) {
        self.text = text
        self.router = router
    }

    var body: some View {
        ZStack {
            switch state.step {
            case .confirm1:
                Confirm1View(
                    text: text,
                    router: router,
                    onNext: { state.step = .confirm2 }
                )
                .transition(.move(edge: .leading))
            case .confirm2:
                Confirm2View(
                    text: text,
                    router: router,
                    onBack: { state.step = .confirm1 }
                )
                .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut, value: state.step)
    }
}

/// プレビュー用の何もしない UseCase スタブ。
private struct PreviewSubmitTodoUseCase: SubmitTodoUseCase {
    func execute(text: String) async throws {}
}

/// プレビュー用の何もしない Router スタブ。
private final class PreviewConfirmFlowRouter: ConfirmFlowRouter {
    func navigateToComplete() {}
    func navigateBack() {}
}

#Preview {
    let _ = Container.shared.submitTodoUseCase.register { PreviewSubmitTodoUseCase() }
    ConfirmFlowView(text: "牛乳を買う", router: PreviewConfirmFlowRouter())
}
