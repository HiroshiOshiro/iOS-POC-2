import Foundation
import FactoryKit
import Domain
import Data

/// ログイン画面の ViewModel。モック API でログインし、結果のセッションを保持する。
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var session: Session?
    @Published private(set) var errorMessage: String?

    @Injected(\.loginUseCase) private var loginUseCase
    @Injected(\.loadSessionUseCase) private var loadSessionUseCase

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    /// 保存済みのセッション（UserDefaults の email ＋ Keychain の userID）を復元する。
    func onAppear() {
        Task { [weak self] in
            guard let self else { return }
            self.session = await self.loadSessionUseCase.execute()
        }
    }

    func loginButtonTapped() {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                self.session = try await self.loginUseCase.execute(
                    email: self.email,
                    password: self.password
                )
                // パスワードは保持しない。
                self.password = ""
            } catch {
                self.errorMessage = L("login.error")
            }
            self.isLoading = false
        }
    }
}
