#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 確認画面②。さらに内容を確認し「保存」でフェイク API 呼び出し・永続化を行い完了画面へ遷移する。
@interface Confirm2ViewController : UIViewController

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
