#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CustomNavBar)

/// 独自ナビゲーションバーを画面最上部に設置する。
/// 戻るボタン有効時は自動で pop する。返り値の `bottomAnchor` にコンテンツを合わせる。
- (CustomNavigationBar *)installCustomNavigationBarWithTitle:(nullable NSString *)title
                                            showsBackButton:(BOOL)showsBackButton;

@end

NS_ASSUME_NONNULL_END
