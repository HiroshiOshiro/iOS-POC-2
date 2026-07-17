import SwiftUI
import FactoryKit
import Domain
import Data

/// ログイン画面。メールアドレス／パスワードを入力し、モック API でログインする。
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    /// メールアドレスは LocalStorage 層が UserDefaults の同じキーへ保存するため、
    /// ここでは @AppStorage で購読して表示する（保存後に自動で反映される）。
    @AppStorage(StorageKeys.loginEmail) private var savedEmail: String = ""

    var body: some View {
        CustomNavigationBarView(title: L("login.title")) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField(L("login.email"), text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField(L("login.password"), text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    Button(action: { viewModel.loginButtonTapped() }) {
                        Text(L("login.button")).font(.headline)
                    }
                    .disabled(!viewModel.canSubmit)

                    if viewModel.isLoading {
                        ProgressView()
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    if let session = viewModel.session {
                        Divider().padding(.vertical, 8)
                        Text(L("login.saved_title")).font(.headline)
                        Text("\(L("login.saved_email")): \(savedEmail)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text("\(L("login.saved_user_id")): \(session.userID)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
            }
        }
        .onAppear { viewModel.onAppear() }
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

#Preview {
    let _ = Container.shared.loginUseCase.register { PreviewLoginUseCase() }
    let _ = Container.shared.loadSessionUseCase.register { PreviewLoadSessionUseCase() }
    LoginView()
}
