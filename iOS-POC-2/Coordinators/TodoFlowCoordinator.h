#import <UIKit/UIKit.h>
#import "TodoInputViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// Todo の入力〜確認〜完了フローの画面遷移を一元管理する Coordinator。
/// 各画面（入力・完了）は自身の遷移を知らず、この Coordinator が順序を所有する。
@interface TodoFlowCoordinator : NSObject <TodoInputViewControllerDelegate>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                         inputViewController:(TodoInputViewController *)inputViewController;

@end

NS_ASSUME_NONNULL_END
