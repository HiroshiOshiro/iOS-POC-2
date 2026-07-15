#import <Foundation/Foundation.h>
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

/// iTunes Search API（キー不要）で楽曲を検索するクライアント。
/// https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/
@interface ITunesAPIClient : NSObject

+ (instancetype)sharedClient;

/// 楽曲を検索する。日本ストア・日本語表記で取得する。
/// @param term 検索語
/// @param completion メインスレッドで呼ばれる。成功時は tracks、失敗時は error。
- (void)searchTracksWithTerm:(NSString *)term
                  completion:(void (^)(NSArray<Track *> *_Nullable tracks,
                                       NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
