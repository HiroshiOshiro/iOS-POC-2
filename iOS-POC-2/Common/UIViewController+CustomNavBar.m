#import "UIViewController+CustomNavBar.h"

@implementation UIViewController (CustomNavBar)

- (CustomNavigationBar *)installCustomNavigationBarWithTitle:(NSString *)title
                                            showsBackButton:(BOOL)showsBackButton {
    CustomNavigationBar *bar = [[CustomNavigationBar alloc] initWithTitle:title
                                                         showsBackButton:showsBackButton];
    [self.view addSubview:bar];

    if (showsBackButton) {
        __weak typeof(self) weakSelf = self;
        bar.onBack = ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
    }

    // ステータスバー領域も覆うよう view の最上端に合わせる。
    [NSLayoutConstraint activateConstraints:@[
        [bar.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [bar.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [bar.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
    ]];
    return bar;
}

@end
