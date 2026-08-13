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

    /// 実行中のログイン処理。画面を閉じたときにキャンセルできるよう保持しておく。
    private var loginTask: Task<Void, Never>?
    /// alert の「リトライ」が押されたときに実行する処理。失敗した箇所で都度差し替える。
    /// - 循環参照を避けるため必ず `[weak self]` で捕まえる（`self` がこのクロージャを
    ///   プロパティとして保持するため、強参照だと循環してしまう）。
    /// - 失敗した**瞬間の値**（例: 当時の email/password）は絶対にキャプチャしない。
    ///   `loginButtonTapped()` 自身が呼ばれた時点の `self.email`/`self.password` を
    ///   読み直す作りなので、ここではそれをそのまま呼ぶだけにする。値をキャプチャすると、
    ///   「エラー表示中に入力し直してからリトライ」しても古い値で再送してしまうバグになる。
    private var retryAction: (() -> Void)?

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
                self.setRetryableAccessCheckError(.accessDenied)
            }
        } catch let failure as AuthError {
            log("アクセス権限チェック失敗: \(failure)")
            let mapped: LoginError = switch failure {
            case .transport: .network
            default:         .unknown
            }
            self.setRetryableAccessCheckError(mapped)
        } catch {
            log("アクセス権限チェック失敗(想定外): \(error)")
            self.setRetryableAccessCheckError(.unknown)
        }
    }

    /// アクセス許可チェックの失敗を表示し、「リトライ」で同じチェックをもう一度実行できるようにする。
    private func setRetryableAccessCheckError(_ error: LoginError) {
        self.error = error
        self.retryAction = { [weak self] in
            Task { [weak self] in
                guard let self else { return }
                await self.checkAccessPermission()
            }
        }
    }

    /// 画面が非表示になったとき（タブ切り替え等）に呼ぶ。実行中のログイン処理を中断する。
    func onDisappear() {
        loginTask?.cancel()
    }

    func loginButtonTapped() {
        guard canSubmit else { return }
        isLoading = true
        error = nil
        // 前回分がまだ残っていれば（通常は無いはずだが念のため）キャンセルしてから差し替える。
        loginTask?.cancel()
        loginTask = Task { [weak self] in
            guard let self else { return }
            do {
                let session = try await self.loginUseCase.execute(
                    email: self.email,
                    password: self.password
                )
                // execute() が返ってきた直後にキャンセルされている可能性があるので、
                // 結果を UI へ反映する前にもう一度だけ確認する。
                guard !Task.isCancelled else {
                    self.isLoading = false
                    return
                }
                self.session = session
                // パスワードは保持しない。
                self.password = ""
            } catch is CancellationError {
                // 画面を閉じた等で中断された。UI へは何も反映しない。
                log("ログインAPI呼び出しをキャンセル")
                self.isLoading = false
                return
            } catch let failure as AuthError {
                guard !Task.isCancelled else { self.isLoading = false; return }
                // どの段で失敗したか（Domain の AuthError）で表示を切り替える。
                log("ログイン失敗: \(failure)")
                let mapped: LoginError = switch failure {
                case .validation:   .validation
                case .encryption:   .encryption
                case .persistence:  .persistence
                case .transport:    .network // Login の通信失敗はまとめて通信エラー表示
                case .missingToken: .unknown // ログイン処理自体では起きない段だが網羅性のため
                case .unknown:      .unknown
                }
                self.setRetryableLoginError(mapped)
            } catch {
                guard !Task.isCancelled else { self.isLoading = false; return }
                // 想定外はまとめて unknown 表示。
                log("ログイン失敗(想定外): \(error)")
                self.setRetryableLoginError(.unknown)
            }
            self.isLoading = false
        }
    }

    /// ログイン失敗を表示し、「リトライ」でログインをもう一度実行できるようにする。
    private func setRetryableLoginError(_ error: LoginError) {
        self.error = error
        self.retryAction = { [weak self] in
            self?.loginButtonTapped()
        }
    }

    /// ネットワークエラーの alert から「リトライ」が押されたときに、失敗した処理を再実行する。
    func retryButtonTapped() {
        retryAction?()
    }

    /// アラートを閉じたときにエラー状態を解除する。
    func dismissError() {
        error = nil
        retryAction = nil
    }
}
