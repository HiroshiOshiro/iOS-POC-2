import Testing
import FactoryKit
import Domain
import ConfirmApi
@testable import ConfirmImpl

@MainActor
struct Confirm2ViewModelTests {

    // MARK: Stubs

    struct StubSubmitTodoUseCase: SubmitTodoUseCase {
        let shouldThrow: Bool
        func execute(text: String) async throws {
            if shouldThrow { throw StubError.failed }
        }
    }

    @MainActor
    final class SpyRouter: ConfirmFlowRouter {
        private(set) var didNavigateToComplete = false
        private(set) var didNavigateBack = false
        func navigateToComplete() { didNavigateToComplete = true }
        func navigateBack() { didNavigateBack = true }
    }

    private func makeSUT(shouldThrow: Bool, router: SpyRouter) -> Confirm2ViewModel {
        Container.shared.submitTodoUseCase.register { StubSubmitTodoUseCase(shouldThrow: shouldThrow) }
        return Confirm2ViewModel(text: "牛乳を買う", router: router, onBack: {})
    }

    @Test("Given submit succeeds, when save is tapped, then it navigates to complete with no error")
    func saveSuccessNavigates() async {
        let router = SpyRouter()
        let sut = makeSUT(shouldThrow: false, router: router)

        sut.saveButtonTapped()
        await waitUntil { !sut.isSubmitting }

        #expect(router.didNavigateToComplete == true)
        #expect(sut.error == nil)
    }

    @Test("Given submit fails, when save is tapped, then it sets an error and does not navigate")
    func saveFailureShowsError() async {
        let router = SpyRouter()
        let sut = makeSUT(shouldThrow: true, router: router)

        sut.saveButtonTapped()
        await waitUntil { !sut.isSubmitting }

        #expect(router.didNavigateToComplete == false)
        #expect(sut.error != nil)
    }

    @Test("ConfirmError provides a localized description")
    func confirmErrorIsLocalized() {
        #expect(ConfirmError.submitFailed.errorDescription == "保存に失敗しました")
    }
}
