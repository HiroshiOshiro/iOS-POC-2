#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 保存処理を模したフェイク API クライアント。
/// 実際の通信は行わず、一定時間後に成功コールバックを返す。
@interface FakeAPIClient : NSObject

+ (instancetype)sharedClient;

/// Todo を送信する体でフェイク処理を行う。
/// @param text 送信対象のテキスト
/// @param completion メインスレッドで呼ばれる完了コールバック
- (void)submitTodoText:(NSString *)text
            completion:(void (^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
