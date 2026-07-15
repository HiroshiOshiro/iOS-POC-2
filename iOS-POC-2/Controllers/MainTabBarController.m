#import "MainTabBarController.h"
#import "TodoInputViewController.h"
#import "MemoViewController.h"

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    // タブ①: Todo（ナビゲーションで複数画面を遷移する）
    TodoInputViewController *todoVC = [[TodoInputViewController alloc] init];
    UINavigationController *todoNav =
        [[UINavigationController alloc] initWithRootViewController:todoVC];
    todoNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Todo"
                                                       image:[UIImage systemImageNamed:@"checklist"]
                                                         tag:0];

    // タブ②: Memo（空タブ）
    MemoViewController *memoVC = [[MemoViewController alloc] init];
    memoVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Memo"
                                                      image:[UIImage systemImageNamed:@"note.text"]
                                                        tag:1];

    self.viewControllers = @[ todoNav, memoVC ];
}

@end
