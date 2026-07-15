#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 完了画面。完了メッセージを表示し「入力に戻る」で入力画面へ戻る。
/// 実際の遷移は Coordinator が `onBackToInput` で管理する。
@interface CompletionViewController : UIViewController

/// 「入力に戻る」タップ時に呼ばれる。
@property (nonatomic, copy, nullable) void (^onBackToInput)(void);

@end

NS_ASSUME_NONNULL_END
