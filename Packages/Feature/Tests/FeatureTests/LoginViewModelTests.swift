import Testing
import FactoryKit
import Model
import Domain
@testable import LoginImpl

// @Injected は Container.shared から解決するため、スタブは register で差し替える。
@MainActor
@Suite(.serialized)
struct LoginViewModelTests {

    // MARK: Stubs

    /// session が nil のときは失敗（throw）を模す。
    struct StubLoginUseCase: LoginUseCase {
        let session: Session?
        func execute(email: String, password: String) async throws -> Session {
            guard let session else { throw StubError.failed }
            return session
        }
    }

    struct StubLoadSessionUseCase: LoadSessionUseCase {
        func execute() async -> Session? { nil }
    }

    private func makeSUT(
        session: Session?,
        onLoginSuccess: @escaping (Session) -> Void = { _ in }
    ) -> LoginViewModel {
        Container.shared.loginUseCase.register { StubLoginUseCase(session: session) }
        Container.shared.loadSessionUseCase.register { StubLoadSessionUseCase() }
        return LoginViewModel(onLoginSuccess: onLoginSuccess)
    }

    // MARK: canSubmit

    @Test("Given empty fields, then canSubmit is false")
    func canSubmitFalseWhenEmpty() {
        let sut = makeSUT(session: nil)
        sut.email = ""
        sut.password = ""
        #expect(sut.canSubmit == false)
    }

    @Test("Given both fields filled, then canSubmit is true")
    func canSubmitTrueWhenFilled() {
        let sut = makeSUT(session: nil)
        sut.email = "user@example.com"
        sut.password = "pw"
        #expect(sut.canSubmit == true)
    }

    // MARK: login

    @Test("Given login succeeds, when login is tapped, then a session is set and the password is cleared")
    func loginSuccess() async {
        let session = Session(email: "user@example.com", userID: "user-1")
        let sut = makeSUT(session: session)
        sut.email = "user@example.com"
        sut.password = "pw"

        sut.loginButtonTapped()
        await waitUntil { !sut.isLoading }

        #expect(sut.session == session)
        #expect(sut.error == nil)
        #expect(sut.password == "")
    }

    @Test("Given login fails, when login is tapped, then an error is set and no session")
    func loginFailure() async {
        let sut = makeSUT(session: nil)
        sut.email = "user@example.com"
        sut.password = "pw"

        sut.loginButtonTapped()
        await waitUntil { !sut.isLoading }

        #expect(sut.error != nil)
        #expect(sut.session == nil)
    }

    @Test("Given login succeeds, when login is tapped, then onLoginSuccess is called with the session")
    func loginSuccessNotifiesOnLoginSuccess() async {
        let session = Session(email: "user@example.com", userID: "user-1")
        var received: Session?
        let sut = makeSUT(session: session, onLoginSuccess: { received = $0 })
        sut.email = "user@example.com"
        sut.password = "pw"

        sut.loginButtonTapped()
        await waitUntil { !sut.isLoading }

        #expect(received == session)
    }

    @Test("Given login fails, when login is tapped, then onLoginSuccess is not called")
    func loginFailureDoesNotNotifyOnLoginSuccess() async {
        var called = false
        let sut = makeSUT(session: nil, onLoginSuccess: { _ in called = true })
        sut.email = "user@example.com"
        sut.password = "pw"

        sut.loginButtonTapped()
        await waitUntil { !sut.isLoading }

        #expect(called == false)
    }

    // MARK: LocalizedError

    @Test("LoginError provides a localized description")
    func loginErrorIsLocalized() {
        #expect(LoginError.unknown.errorDescription == "ログインに失敗しました")
    }
}
