import UIKit
import Feature

/// Todo の入力〜確認〜完了フローの画面遷移を一元管理する Coordinator。
/// 各画面（入力・完了）は自身の遷移を知らず、この Coordinator が順序を所有する。
/// ObjC 画面（TodoInputViewController / CompletionViewController）を扱うためアプリターゲットに置く。
@MainActor
@objc final class TodoFlowCoordinator: NSObject, TodoInputViewControllerDelegate {
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
        let flow = ConfirmFlowFactory.makeConfirmFlow(
            text: text,
            onCompleted: { [weak self] in self?.showCompletion() },
            onExit: { [weak self] in self?.navigationController?.popViewController(animated: true) }
        )
        navigationController?.pushViewController(flow, animated: true)
    }

    // MARK: - Navigation

    private func showCompletion() {
        // 保存完了 → 入力欄をリセットし、完了画面へ。
        inputViewController?.resetInput()

        let completionVC = CompletionViewController()
        completionVC.onBackToInput = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
        navigationController?.pushViewController(completionVC, animated: true)
    }
}
