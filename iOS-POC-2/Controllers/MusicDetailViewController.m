#import "MusicDetailViewController.h"
#import "ImageLoader.h"
#import "UIViewController+CustomNavBar.h"
#import <AVFoundation/AVFoundation.h>
#import <SafariServices/SafariServices.h>

@interface MusicDetailViewController ()
@property (nonatomic, strong) Track *track;
@property (nonatomic, strong) UIImageView *artworkView;
@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation MusicDetailViewController

- (instancetype)initWithTrack:(Track *)track {
    self = [super init];
    if (self) {
        _track = track;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player pause];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"music.detail.title", nil);
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    [self setupViews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 画面を離れたら試聴を停止する。
    [self stopPreview];
}

#pragma mark - Setup

- (void)setupViews {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollView];

    UIStackView *stack = [[UIStackView alloc] init];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 12;
    [scrollView addSubview:stack];

    // アートワーク
    self.artworkView = [[UIImageView alloc] init];
    self.artworkView.translatesAutoresizingMaskIntoConstraints = NO;
    self.artworkView.contentMode = UIViewContentModeScaleAspectFill;
    self.artworkView.clipsToBounds = YES;
    self.artworkView.layer.cornerRadius = 12;
    self.artworkView.backgroundColor = [UIColor systemGray5Color];
    [stack addArrangedSubview:self.artworkView];
    [self loadArtwork];

    // 曲名
    UILabel *titleLabel = [self labelWithFont:[UIFont boldSystemFontOfSize:22]
                                        color:[UIColor labelColor]];
    titleLabel.text = self.track.trackName ?: NSLocalizedString(@"music.detail.unknown_title", nil);
    [stack addArrangedSubview:titleLabel];

    // アーティスト
    UILabel *artistLabel = [self labelWithFont:[UIFont systemFontOfSize:17]
                                         color:[UIColor secondaryLabelColor]];
    artistLabel.text = self.track.artistName;
    [stack addArrangedSubview:artistLabel];

    // メタ情報（アルバム / ジャンル / リリース日 / 再生時間）
    UILabel *metaLabel = [self labelWithFont:[UIFont systemFontOfSize:14]
                                       color:[UIColor tertiaryLabelColor]];
    metaLabel.text = [self metaText];
    [stack addArrangedSubview:metaLabel];

    [stack setCustomSpacing:24 afterView:metaLabel];

    // 試聴ボタン
    self.previewButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.previewButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.previewButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self updatePreviewButtonTitle];
    [self.previewButton addTarget:self
                           action:@selector(didTapPreview)
                 forControlEvents:UIControlEventTouchUpInside];
    self.previewButton.enabled = (self.track.previewUrl.length > 0);
    [stack addArrangedSubview:self.previewButton];

    // iTunes で開くボタン
    UIButton *openButton = [UIButton buttonWithType:UIButtonTypeSystem];
    openButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [openButton setTitle:NSLocalizedString(@"music.detail.open_itunes", nil) forState:UIControlStateNormal];
    [openButton addTarget:self
                   action:@selector(didTapOpenITunes)
         forControlEvents:UIControlEventTouchUpInside];
    openButton.enabled = (self.track.trackViewUrl.length > 0);
    [stack addArrangedSubview:openButton];

    // 独自ナビゲーションバー（戻るボタンあり）
    CustomNavigationBar *navBar =
        [self installCustomNavigationBarWithTitle:NSLocalizedString(@"music.detail.title", nil)
                                  showsBackButton:YES];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [scrollView.topAnchor constraintEqualToAnchor:navBar.bottomAnchor],
        [scrollView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor],
        [scrollView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor],
        [scrollView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor],

        [stack.topAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.topAnchor constant:24],
        [stack.bottomAnchor constraintEqualToAnchor:scrollView.contentLayoutGuide.bottomAnchor constant:-24],
        [stack.leadingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:scrollView.frameLayoutGuide.trailingAnchor constant:-24],

        [self.artworkView.widthAnchor constraintEqualToAnchor:stack.widthAnchor multiplier:0.8],
        [self.artworkView.heightAnchor constraintEqualToAnchor:self.artworkView.widthAnchor],
    ]];
}

- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (NSString *)metaText {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (self.track.collectionName.length > 0) {
        [parts addObject:self.track.collectionName];
    }
    if (self.track.primaryGenreName.length > 0) {
        [parts addObject:self.track.primaryGenreName];
    }
    if (self.track.releaseDateText.length > 0) {
        [parts addObject:self.track.releaseDateText];
    }
    if (self.track.durationText.length > 0) {
        [parts addObject:self.track.durationText];
    }
    return [parts componentsJoinedByString:@" ・ "];
}

- (void)loadArtwork {
    NSString *urlString = self.track.artworkUrlLarge ?: self.track.artworkUrl100;
    __weak typeof(self) weakSelf = self;
    [[ImageLoader sharedLoader] loadImageFromURLString:urlString
                                            completion:^(UIImage *image) {
        if (image) {
            weakSelf.artworkView.image = image;
        }
    }];
}

#pragma mark - Preview playback

- (void)didTapPreview {
    if (self.isPlaying) {
        [self stopPreview];
        return;
    }
    NSURL *url = [NSURL URLWithString:self.track.previewUrl];
    if (!url) {
        return;
    }
    if (!self.player) {
        self.player = [AVPlayer playerWithURL:url];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(previewDidFinish)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.player.currentItem];
    }
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    self.isPlaying = YES;
    [self updatePreviewButtonTitle];
}

- (void)stopPreview {
    [self.player pause];
    self.isPlaying = NO;
    [self updatePreviewButtonTitle];
}

- (void)previewDidFinish {
    self.isPlaying = NO;
    [self updatePreviewButtonTitle];
}

- (void)updatePreviewButtonTitle {
    NSString *title = self.isPlaying
                          ? NSLocalizedString(@"music.detail.preview_stop", nil)
                          : NSLocalizedString(@"music.detail.preview_play", nil);
    [self.previewButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Open iTunes

- (void)didTapOpenITunes {
    NSURL *url = [NSURL URLWithString:self.track.trackViewUrl];
    if (!url) {
        return;
    }
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:safari animated:YES completion:nil];
}

@end
