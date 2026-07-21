import UIKit
import ConfirmApi
import ConfirmImpl

/// Todo の入力〜確認〜完了フローの画面遷移を一元管理する Coordinator。
/// 各画面（入力・確認・完了）は自身の遷移を知らず、この Coordinator が順序を所有する。
/// Feature からは `ConfirmFlowRouter` として遷移を依頼される。
/// ObjC 画面（TodoInputViewController / CompletionViewController）を扱うためアプリターゲットに置く。
/// NiA 相当なし: NiA は NavHost + 各 feature の EntryProvider で遷移を組む。Coordinator は
/// ObjC/UIKit と SwiftUI をまたぐ本 POC の事情による構成で、NiA には対応物がない。
@MainActor
@objc final class TodoFlowCoordinator: NSObject, TodoInputViewControllerDelegate, ConfirmFlowRouter {
    private weak var navigationController: UINavigationController?
    private weak var inputViewController: TodoInputViewController?

    @objc init(navigationController: UINavigationController,
               inputViewController: TodoInputViewController) {
        self.navigationController = navigationController
        self.inputViewController = inputViewController
        super.init()
        inputViewController.flowDelegate = self
    }

    // MARK: - TodoInputViewControllerDelegate

    func todoInputViewController(_ controller: TodoInputViewController, didSubmitText text: String) {
        // 確認フロー（確認画面1→2）は Swift の Feature パッケージが提供する。
        let flow = ConfirmFlowFactory.makeConfirmFlow(text: text, router: self)

        navigationController?.pushViewController(flow, animated: true)
    }

    // MARK: - ConfirmFlowRouter

    func navigateToComplete() {
        // 保存完了 → 入力欄をリセットし、完了画面へ。
        inputViewController?.resetInput()

        let completionVC = CompletionViewController()
        completionVC.onBackToInput = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(completionVC, animated: true)
    }

    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}
