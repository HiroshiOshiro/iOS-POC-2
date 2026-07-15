#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 独自 UI のナビゲーションバー（UIView として自作）。
/// システムの UINavigationBar を隠し、各画面の最上部にこのビューを配置して使う。
/// ステータスバー領域まで背景を伸ばし、下 44pt にタイトル・戻るボタンを配置する。
@interface CustomNavigationBar : UIView

- (instancetype)initWithTitle:(nullable NSString *)title
              showsBackButton:(BOOL)showsBackButton;

/// 戻るボタンが押されたときに呼ばれる。
@property (nonatomic, copy, nullable) void (^onBack)(void);

/// タイトルラベル（必要に応じて外から文言変更できるよう公開）。
@property (nonatomic, strong, readonly) UILabel *titleLabel;

@end

NS_ASSUME_NONNULL_END
