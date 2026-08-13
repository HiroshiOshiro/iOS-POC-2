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
    @Injected(\.checkAccessPermissionUseCase) private var checkAccessPermissionUseCase

    var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isLoading
    }

    /// 保存済みのセッション（UserDefaults の email ＋ Keychain の userID）を復元する。
    /// アクセス許可チェックとは互いに依存しない別々の関心ごとなので、別の Task にする。
    func onAppear() {
        Task { [weak self] in
            guard let self else { return }
            self.session = await self.loadSessionUseCase.execute()
        }
        Task { [weak self] in
            guard let self else { return }
            await self.checkAccessPermission()
        }
    }

    /// 現在のトークンにアクセス許可があるかを確認する。拒否・失敗時は alert を出すが、
    /// フォームはブロックしない（`error` は `.alert` の表示だけで、他の操作を無効化しない）。
    private func checkAccessPermission() async {
        do {
            let allowed = try await checkAccessPermissionUseCase.execute()
            if !allowed {
                log("アクセス権限チェック: 拒否")
                self.error = .accessDenied
            }
        } catch let failure as AuthError {
            log("アクセス権限チェック失敗: \(failure)")
            self.error = switch failure {
            case .transport: .network
            default:         .unknown
            }
        } catch {
            log("アクセス権限チェック失敗(想定外): \(error)")
            self.error = .unknown
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
            } catch let failure as AuthError {
                // どの段で失敗したか（Domain の AuthError）で表示を切り替える。
                log("ログイン失敗: \(failure)")
                self.error = switch failure {
                case .validation:   .validation
                case .encryption:   .encryption
                case .persistence:  .persistence
                case .transport:    .network // Login の通信失敗はまとめて通信エラー表示
                case .missingToken: .unknown // ログイン処理自体では起きない段だが網羅性のため
                case .unknown:      .unknown
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
