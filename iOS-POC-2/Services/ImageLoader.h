#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// URL から画像を非同期取得し、メモリキャッシュする軽量ローダー。
@interface ImageLoader : NSObject

+ (instancetype)sharedLoader;

/// 画像を取得する。キャッシュがあれば即座に、無ければダウンロード後に
/// メインスレッドで completion を呼ぶ。
- (void)loadImageFromURLString:(NSString *)urlString
                    completion:(void (^)(UIImage *_Nullable image))completion;

@end

NS_ASSUME_NONNULL_END
