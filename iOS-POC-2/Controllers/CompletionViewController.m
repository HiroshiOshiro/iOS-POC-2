#import "CompletionViewController.h"

@implementation CompletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"完了";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    // 完了画面からは戻るジェスチャ・戻るボタンを無効化する。
    self.navigationItem.hidesBackButton = YES;
    [self setupViews];
}

- (void)setupViews {
    // 「完了しました」メッセージ
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = @"完了しました";
    messageLabel.font = [UIFont boldSystemFontOfSize:28];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:messageLabel];

    // 「入力に戻る」ボタン
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setTitle:@"入力に戻る" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [backButton addTarget:self
                   action:@selector(didTapBackToInput)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [messageLabel.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:guide.centerYAnchor constant:-20],

        [backButton.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:40],
        [backButton.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
    ]];
}

- (void)didTapBackToInput {
    // スタックの先頭（入力画面）まで戻る。
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
