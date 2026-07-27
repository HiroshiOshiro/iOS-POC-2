#import "MainTabBarController.h"
#import "TodoInputViewController.h"
#import "iOS-POC-2-Swift.h"
@import LoginImpl;
@import MusicImpl;

@interface MainTabBarController ()
// Todo フローの遷移を所有する Coordinator を保持する。
@property (nonatomic, strong) TodoFlowCoordinator *todoFlowCoordinator;
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    // タブ①: Todo（ナビゲーションで複数画面を遷移する）
    TodoInputViewController *todoVC = [[TodoInputViewController alloc] init];
    UINavigationController *todoNav =
        [[UINavigationController alloc] initWithRootViewController:todoVC];
    // システムのナビゲーションバーは隠し、各画面で独自の CustomNavigationBar を使う。
    todoNav.navigationBarHidden = YES;
    todoNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab.todo", nil)
                                                       image:[UIImage imageNamed:@"todo"]
                                                         tag:0];
    // Todo フローの遷移管理は Coordinator が担う。
    self.todoFlowCoordinator =
        [[TodoFlowCoordinator alloc] initWithNavigationController:todoNav
                                             inputViewController:todoVC];

    // タブ②: Music（Swift/SwiftUI。iTunes Search API で一覧→詳細。遷移は内部の NavigationView）
    UIViewController *musicVC = [MusicScreenFactory makeMusicScreen];
    musicVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab.music", nil)
                                                       image:[UIImage imageNamed:@"music"]
                                                         tag:1];

    // タブ③: Login（Swift/SwiftUI。単一画面なのでナビゲーションは持たない）
    UIViewController *loginVC = [LoginScreenFactory makeLoginScreen];
    loginVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab.login", nil)
                                                       image:[UIImage imageNamed:@"login"]
                                                         tag:2];

    self.viewControllers = @[ todoNav, musicVC, loginVC ];
}

@end
