#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 確認画面①。入力画面で入力した文字を確認し「次へ」で確認画面②へ遷移する。
@interface Confirm1ViewController : UIViewController

- (instancetype)initWithText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
