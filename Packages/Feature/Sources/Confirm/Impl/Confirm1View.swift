import SwiftUI
import DesignSystem
import ConfirmApi

/// 確認画面1。入力内容を表示し「次へ」で確認画面2 へ進む。
struct Confirm1View: View {
    @StateObject private var viewModel: Confirm1ViewModel

    init(text: String, router: ConfirmFlowRouter, onNext: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: Confirm1ViewModel(text: text, router: router, onNext: onNext)
        )
    }

    var body: some View {
        CustomNavigationBarView(
            title: L("confirm1.title"),
            showsBack: true,
            onBack: { viewModel.backButtonTapped() }
        ) {
            VStack(spacing: 16) {
                Spacer()
                Text(L("confirm1.caption"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(viewModel.text)
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                Button(action: { viewModel.nextButtonTapped() }) {
                    Text(L("confirm1.next")).font(.headline)
                }
                .padding(.top, 24)
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

/// プレビュー用の何もしない Router スタブ。
private final class PreviewConfirmFlowRouter: ConfirmFlowRouter {
    func navigateToComplete() {}
    func navigateBack() {}
}

#Preview {
    Confirm1View(text: "牛乳を買う", router: PreviewConfirmFlowRouter(), onNext: {})
}
