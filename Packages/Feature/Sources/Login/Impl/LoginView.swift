import SwiftUI
import DesignSystem
import FactoryKit
import Model
import Domain
import Data
import Datastore

/// ログイン画面。メールアドレス／パスワードを入力し、モック API でログインする。
/// NiA 相当: feature:*:impl の Screen（`TopicScreen` / `InterestsScreen`）。
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    /// メールアドレスは LocalStorage 層が UserDefaults の同じキーへ保存するため、
    /// ここでは @AppStorage で購読して表示する（保存後に自動で反映される）。
    @AppStorage(StorageKeys.loginEmail) private var savedEmail: String = ""

    /// 利用規約アコーディオンの開閉状態。
    @State private var isTermsExpanded = false

    var body: some View {
        CustomNavigationBarView(title: L("login.title")) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // アイコン（SF Symbol をブランドカラーで大きく表示）
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(Color.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)

                    TextField(L("login.email"), text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField(L("login.password"), text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    // ブランドカラーの塗りボタンに装飾。
                    Button(action: { viewModel.loginButtonTapped() }) {
                        Text(L("login.button"))
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.brand, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(!viewModel.canSubmit)
                    .opacity(viewModel.canSubmit ? 1 : 0.5)

                    if viewModel.isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    }

                    // 利用規約（アコーディオン表示）
                    DisclosureGroup(isExpanded: $isTermsExpanded) {
                        Text(L("login.terms_body"))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                    } label: {
                        Text(L("login.terms_title"))
                            .font(.subheadline.weight(.semibold))
                    }
                    .tint(Color.brand)

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
        .alert(
            L("error.title"),
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.dismissError() } }
            ),
            presenting: viewModel.error
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { error in
            Text(error.localizedDescription)
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

#Preview {
    let _ = Container.shared.loginUseCase.register { PreviewLoginUseCase() }
    let _ = Container.shared.loadSessionUseCase.register { PreviewLoadSessionUseCase() }
    LoginView()
}
