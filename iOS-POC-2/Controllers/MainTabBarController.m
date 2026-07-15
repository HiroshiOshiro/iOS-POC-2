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
    todoNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Todo"
                                                       image:[UIImage systemImageNamed:@"checklist"]
                                                         tag:0];

    // タブ②: Music（iTunes Search API で一覧→詳細）
    MusicListViewController *musicVC = [[MusicListViewController alloc] init];
    UINavigationController *musicNav =
        [[UINavigationController alloc] initWithRootViewController:musicVC];
    musicNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Music"
                                                        image:[UIImage systemImageNamed:@"music.note"]
                                                          tag:1];

    self.viewControllers = @[ todoNav, musicNav ];
}

@end
