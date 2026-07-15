#import "Confirm1ViewController.h"
#import "Confirm2ViewController.h"

@interface Confirm1ViewController ()
@property (nonatomic, copy) NSString *inputText;
@end

@implementation Confirm1ViewController

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _inputText = [text copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"確認①";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)setupViews {
    UILabel *captionLabel = [[UILabel alloc] init];
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    captionLabel.text = @"入力内容を確認してください";
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

    // 「次へ」ボタン
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [nextButton setTitle:@"次へ" forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [nextButton addTarget:self
                   action:@selector(didTapNext)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [captionLabel.centerYAnchor constraintEqualToAnchor:guide.centerYAnchor constant:-60],
        [captionLabel.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],

        [valueLabel.topAnchor constraintEqualToAnchor:captionLabel.bottomAnchor constant:16],
        [valueLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:24],
        [valueLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:-24],

        [nextButton.topAnchor constraintEqualToAnchor:valueLabel.bottomAnchor constant:48],
        [nextButton.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
    ]];
}

- (void)didTapNext {
    Confirm2ViewController *confirmVC = [[Confirm2ViewController alloc] initWithText:self.inputText];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

@end
