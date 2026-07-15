#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TodoInputViewController;

/// 入力画面からフロー開始を通知するためのデリゲート。
/// 画面遷移そのものは受け手（Coordinator）が管理する。
@protocol TodoInputViewControllerDelegate <NSObject>
/// ユーザーがテキストを確定（保存ボタン）したときに呼ばれる。
- (void)todoInputViewController:(TodoInputViewController *)controller
                  didSubmitText:(NSString *)text;
@end

/// 入力画面。
/// - テキストボックスに Todo を入力し「保存」でフロー開始をデリゲートへ通知する。
/// - 下部に保存済みの Todo 一覧を表示し、横スワイプで削除できる。
/// 確認画面や完了画面への遷移はこの画面では管理しない（Coordinator が担当）。
@interface TodoInputViewController : UIViewController

@property (nonatomic, weak) id<TodoInputViewControllerDelegate> flowDelegate;

/// 入力欄を初期状態に戻す（保存完了後に Coordinator から呼ばれる）。
- (void)resetInput;

@end

NS_ASSUME_NONNULL_END
