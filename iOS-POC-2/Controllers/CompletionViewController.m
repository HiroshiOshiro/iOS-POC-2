#import "CompletionViewController.h"
#import "UIViewController+CustomNavBar.h"

@implementation CompletionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)setupViews {
    // 完了画面は戻れないので戻るボタンなし。
    CustomNavigationBar *navBar =
        [self installCustomNavigationBarWithTitle:NSLocalizedString(@"completion.title", nil)
                                  showsBackButton:NO];

    // ヘッダ（上部中央）: main バンドルの Asset Catalog（todoHeader）と String Catalog を参照。
    UIImageView *headerImageView =
        [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"todoHeader"]];
    headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:headerImageView];

    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerLabel.text = NSLocalizedString(@"todo.header.title", nil);
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:headerLabel];

    // 「完了しました」メッセージ
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.text = NSLocalizedString(@"completion.message", nil);
    messageLabel.font = [UIFont boldSystemFontOfSize:28];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:messageLabel];

    // 「入力に戻る」ボタン
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setTitle:NSLocalizedString(@"completion.back", nil) forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [backButton addTarget:self
                   action:@selector(didTapBackToInput)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        // ヘッダ（上部中央）
        [headerImageView.topAnchor constraintEqualToAnchor:navBar.bottomAnchor constant:16],
        [headerImageView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
        [headerImageView.widthAnchor constraintEqualToConstant:72],
        [headerImageView.heightAnchor constraintEqualToConstant:72],

        [headerLabel.topAnchor constraintEqualToAnchor:headerImageView.bottomAnchor constant:8],
        [headerLabel.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],

        [messageLabel.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
        [messageLabel.centerYAnchor constraintEqualToAnchor:guide.centerYAnchor constant:-20],

        [backButton.topAnchor constraintEqualToAnchor:messageLabel.bottomAnchor constant:40],
        [backButton.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
    ]];
}

- (void)didTapBackToInput {
    // 遷移は Coordinator に委譲する。
    if (self.onBackToInput) {
        self.onBackToInput();
    }
}

@end
