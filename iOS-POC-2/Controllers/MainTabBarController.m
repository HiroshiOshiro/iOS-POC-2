#import "MainTabBarController.h"
#import "TodoInputViewController.h"
#import "MusicListViewController.h"

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

    // タブ②: Music（iTunes Search API で一覧→詳細）
    MusicListViewController *musicVC = [[MusicListViewController alloc] init];
    UINavigationController *musicNav =
        [[UINavigationController alloc] initWithRootViewController:musicVC];
    musicNav.navigationBarHidden = YES;
    musicNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"tab.music", nil)
                                                        image:[UIImage imageNamed:@"music"]
                                                          tag:1];

    self.viewControllers = @[ todoNav, musicNav ];
}

@end
