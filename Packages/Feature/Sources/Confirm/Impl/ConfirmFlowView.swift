import SwiftUI
import ConfirmApi
import FactoryKit
import Domain
import Data

/// 確認画面1→2 を内包するフロー。`NavigationStack` で「次へ」に応じて確認画面2 を
/// push（`navigationDestination(isPresented:)`）、確認2 の「戻る」で pop する。
/// システムのナビゲーションバーは隠し、各画面は独自の `CustomNavigationBarView` を使う。
/// NiA 相当なし: 確認1↔2 を束ねる feature 内のローカルなナビゲーションホスト。
/// NiA は遷移を app の NavHost + 各画面の NavKey で表すため、この容器に対応物はない。
/// （中の `Confirm1View` / `Confirm2View` が NiA の `*Screen` に相当する。）
struct ConfirmFlowView: View {
    private let text: String
    private let router: ConfirmFlowRouter

    /// 確認画面2 を push しているか（`navigationDestination` の起動状態）。
    @State private var showConfirm2 = false

    init(text: String, router: ConfirmFlowRouter) {
        self.text = text
        self.router = router
    }

    var body: some View {
        NavigationStack {
            Confirm1View(
                text: text,
                router: router,
                onNext: { showConfirm2 = true }
            )
            .toolbar(.hidden, for: .navigationBar)
            // 「次へ」で確認画面2 へ push。確認2 の「戻る」で pop（showConfirm2 = false）する。
            .navigationDestination(isPresented: $showConfirm2) {
                Confirm2View(
                    text: text,
                    router: router,
                    onBack: { showConfirm2 = false }
                )
                .toolbar(.hidden, for: .navigationBar)
            }
        }
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
