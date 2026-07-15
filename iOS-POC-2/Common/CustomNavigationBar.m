#import "CustomNavigationBar.h"
#import "AppAppearance.h"

static const CGFloat kBarContentHeight = 44.0;

@interface CustomNavigationBar ()
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIButton *backButton;
@end

@implementation CustomNavigationBar

- (instancetype)initWithTitle:(NSString *)title
              showsBackButton:(BOOL)showsBackButton {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [AppAppearance brandColor];
        [self setupWithTitle:title showsBackButton:showsBackButton];
    }
    return self;
}

- (void)setupWithTitle:(NSString *)title showsBackButton:(BOOL)showsBackButton {
    // タイトル
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = title;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];

    // ステータスバーの下から 44pt をコンテンツ領域とし、
    // その分でこのビュー自身の高さ（bottom）が決まる。
    UILayoutGuide *safe = self.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [_titleLabel.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [_titleLabel.heightAnchor constraintEqualToConstant:kBarContentHeight],
        [_titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [_titleLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [_titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:safe.leadingAnchor constant:56],
        [_titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:safe.trailingAnchor constant:-56],
    ]];

    if (showsBackButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _backButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_backButton setImage:[UIImage systemImageNamed:@"chevron.backward"]
                     forState:UIControlStateNormal];
        _backButton.tintColor = [UIColor whiteColor];
        [_backButton addTarget:self
                        action:@selector(didTapBack)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        [NSLayoutConstraint activateConstraints:@[
            [_backButton.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:8],
            [_backButton.centerYAnchor constraintEqualToAnchor:_titleLabel.centerYAnchor],
            [_backButton.widthAnchor constraintEqualToConstant:44],
            [_backButton.heightAnchor constraintEqualToConstant:44],
        ]];
    }
}

- (void)didTapBack {
    if (self.onBack) {
        self.onBack();
    }
}

@end
