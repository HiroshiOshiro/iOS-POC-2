import SwiftUI
import FactoryKit
import Domain
import Data

/// 確認画面2。内容を再確認し「保存」でフェイク API 送信・永続化を行い完了へ進む。
struct Confirm2View: View {
    @StateObject private var viewModel: Confirm2ViewModel

    init(text: String, router: ConfirmFlowRouter, onBack: @escaping () -> Void) {
        _viewModel = StateObject(
            wrappedValue: Confirm2ViewModel(text: text, router: router, onBack: onBack)
        )
    }

    var body: some View {
        CustomNavigationBarView(
            title: L("confirm2.title"),
            showsBack: true,
            onBack: { viewModel.backButtonTapped() }
        ) {
            VStack(spacing: 16) {
                Spacer()
                Text(L("confirm2.caption"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(viewModel.text)
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                Button(action: { viewModel.saveButtonTapped() }) {
                    Text(L("confirm2.save")).font(.headline)
                }
                .disabled(viewModel.isSubmitting)
                .padding(.top, 24)
                if viewModel.isSubmitting {
                    ProgressView().padding(.top, 8)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

/// プレビュー用の何もしない UseCase スタブ。
private struct PreviewSubmitTodoUseCase: SubmitTodoUseCase {
    func execute(text: String) async {}
}

/// プレビュー用の何もしない Router スタブ。
private final class PreviewConfirmFlowRouter: ConfirmFlowRouter {
    func navigateToComplete() {}
    func navigateBack() {}
}

#Preview {
    let _ = Container.shared.submitTodoUseCase.register { PreviewSubmitTodoUseCase() }
    Confirm2View(text: "牛乳を買う", router: PreviewConfirmFlowRouter(), onBack: {})
}
