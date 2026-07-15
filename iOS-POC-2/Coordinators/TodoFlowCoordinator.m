#import "TodoFlowCoordinator.h"
#import "CompletionViewController.h"
@import Feature;

@interface TodoFlowCoordinator ()
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) TodoInputViewController *inputViewController;
@end

@implementation TodoFlowCoordinator

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                         inputViewController:(TodoInputViewController *)inputViewController {
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        _inputViewController = inputViewController;
        inputViewController.flowDelegate = self;
    }
    return self;
}

#pragma mark - TodoInputViewControllerDelegate

- (void)todoInputViewController:(TodoInputViewController *)controller
                  didSubmitText:(NSString *)text {
    __weak typeof(self) weakSelf = self;
    // 確認フロー（確認画面1→2）は Swift の Feature パッケージが提供する。
    UIViewController *flow = [ConfirmFlowFactory
        makeConfirmFlowWithText:text
                    onCompleted:^{ [weakSelf showCompletion]; }
                         onExit:^{ [weakSelf.navigationController popViewControllerAnimated:YES]; }];
    [self.navigationController pushViewController:flow animated:YES];
}

#pragma mark - Navigation

- (void)showCompletion {
    // 保存完了 → 入力欄をリセットし、完了画面へ。
    [self.inputViewController resetInput];

    __weak typeof(self) weakSelf = self;
    CompletionViewController *completionVC = [[CompletionViewController alloc] init];
    completionVC.onBackToInput = ^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:completionVC animated:YES];
}

@end
