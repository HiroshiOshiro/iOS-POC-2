import Foundation
import Common
import FactoryKit
import Model
import Domain
import Data

/// ログイン画面の ViewModel。モック API でログインし、結果のセッションを保持する。
/// NiA 相当: feature:*:impl の ViewModel（`TopicViewModel`）。
@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var session: Session?
    /// 発生中のエラー（`LocalizedError`）。View は `.alert` でこれを提示する。
    @Published private(set) var error: LoginError?

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
        error = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                self.session = try await self.loginUseCase.execute(
                    email: self.email,
                    password: self.password
                )
                // パスワードは保持しない。
                self.password = ""
            } catch let failure as LoginFailure {
                // どの段で失敗したか（LoginFailure）で表示を切り替える。
                log("ログイン失敗: \(failure)")
                self.error = switch failure {
                case .validation:  .validation
                case .encryption:  .encryption
                case .network:     .network
                case .persistence: .persistence
                }
            } catch {
                // 想定外はまとめて unknown 表示。
                log("ログイン失敗(想定外): \(error)")
                self.error = .unknown
            }
            self.isLoading = false
        }
    }

    /// アラートを閉じたときにエラー状態を解除する。
    func dismissError() {
        error = nil
    }
}
