import SwiftUI
import FactoryKit
import Model
import Domain

/// ログイン画面を内包するフロー。`NavigationStack` でログイン成功時に完了画面を push
/// （`navigationDestination(isPresented:)`）し、完了画面の「戻る」で pop する。
/// システムのナビゲーションバーは隠し、各画面は独自の `CustomNavigationBarView` を使う。
/// NiA 相当なし: ログイン画面↔完了画面を束ねる feature 内のローカルなナビゲーションホスト
/// （`ConfirmFlowView` と同じ位置づけ）。
struct LoginFlowView: View {
    /// 完了画面を push しているか（`navigationDestination` の起動状態）と、その表示に使うセッション。
    @State private var completedSession: Session?

    var body: some View {
        NavigationStack {
            LoginView(onLoginSuccess: { session in completedSession = session })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(
                    isPresented: Binding(
                        get: { completedSession != nil },
                        set: { if !$0 { completedSession = nil } }
                    )
                ) {
                    if let completedSession {
                        LoginCompleteView(
                            session: completedSession,
                            onBack: { self.completedSession = nil }
                        )
                        .toolbar(.hidden, for: .navigationBar)
                    }
                }
        }
    }
}

/// プレビュー用の何もしない UseCase スタブ。
private struct PreviewLoginUseCase: LoginUseCase {
    func execute(email: String, password: String) async throws -> Session {
        Session(email: email, userID: "user-preview")
    }
}

private struct PreviewLoadSessionUseCase: LoadSessionUseCase {
    func execute() async -> Session? { nil }
}

private struct PreviewCheckAccessPermissionUseCase: CheckAccessPermissionUseCase {
    func execute() async throws -> Bool { true }
}

#Preview {
    let _ = Container.shared.loginUseCase.register { PreviewLoginUseCase() }
    let _ = Container.shared.loadSessionUseCase.register { PreviewLoadSessionUseCase() }
    let _ = Container.shared.checkAccessPermissionUseCase.register { PreviewCheckAccessPermissionUseCase() }
    LoginFlowView()
}
