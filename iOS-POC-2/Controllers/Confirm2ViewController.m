#import "Confirm2ViewController.h"
#import "CompletionViewController.h"
#import "FakeAPIClient.h"
#import "TodoStore.h"
#import "TodoItem.h"

@interface Confirm2ViewController ()
@property (nonatomic, copy) NSString *inputText;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation Confirm2ViewController

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _inputText = [text copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"confirm2.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)setupViews {
    UILabel *captionLabel = [[UILabel alloc] init];
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    captionLabel.text = NSLocalizedString(@"confirm2.caption", nil);
    captionLabel.textColor = [UIColor secondaryLabelColor];
    captionLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:captionLabel];

    // 確認用ラベル
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    valueLabel.text = self.inputText;
    valueLabel.numberOfLines = 0;
    valueLabel.font = [UIFont boldSystemFontOfSize:22];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:valueLabel];

    // 「保存」ボタン
    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.saveButton setTitle:NSLocalizedString(@"confirm2.save", nil) forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.saveButton addTarget:self
                        action:@selector(didTapSave)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];

    // API 呼び出し中のインジケータ
    self.spinner = [[UIActivityIndicatorView alloc]
                    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.translatesAutoresizingMaskIntoConstraints = NO;
    self.spinner.hidesWhenStopped = YES;
    [self.view addSubview:self.spinner];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [captionLabel.centerYAnchor constraintEqualToAnchor:guide.centerYAnchor constant:-60],
        [captionLabel.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],

        [valueLabel.topAnchor constraintEqualToAnchor:captionLabel.bottomAnchor constant:16],
        [valueLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:24],
        [valueLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-24],

        [self.saveButton.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:48],
        [self.saveButton.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],

        [self.spinner.topAnchor constraintEqualToAnchor:self.saveButton.bottomAnchor constant:24],
        [self.spinner.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
    ]];
}

- (void)didTapSave {
    // 二重送信防止
    self.saveButton.enabled = NO;
    [self.spinner startAnimating];

    __weak typeof(self) weakSelf = self;
    // フェイクの API 呼び出し処理
    [[FakeAPIClient sharedClient] submitTodoText:self.inputText
                                      completion:^(BOOL success) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.spinner stopAnimating];

        if (success) {
            // SharedPreference（NSUserDefaults）へ保存
            TodoItem *item = [[TodoItem alloc] initWithText:strongSelf.inputText
                                                  createdAt:[NSDate date]];
            [[TodoStore sharedStore] addItem:item];

            // 完了画面へ遷移
            CompletionViewController *completionVC = [[CompletionViewController alloc] init];
            [strongSelf.navigationController pushViewController:completionVC animated:YES];
        } else {
            strongSelf.saveButton.enabled = YES;
        }
    }];
}

@end
