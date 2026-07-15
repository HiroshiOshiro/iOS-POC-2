#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// iTunes Search API の 1 曲を表すモデル。
@interface Track : NSObject

@property (nonatomic, assign) NSInteger trackId;
@property (nonatomic, copy, nullable) NSString *trackName;
@property (nonatomic, copy, nullable) NSString *artistName;
@property (nonatomic, copy, nullable) NSString *collectionName;   // アルバム名
@property (nonatomic, copy, nullable) NSString *primaryGenreName;
@property (nonatomic, copy, nullable) NSString *artworkUrl100;    // 100x100 サムネ
@property (nonatomic, copy, nullable) NSString *previewUrl;       // 30秒試聴 (m4a)
@property (nonatomic, copy, nullable) NSString *trackViewUrl;     // iTunes ページ
@property (nonatomic, copy, nullable) NSString *releaseDate;      // ISO8601 文字列
@property (nonatomic, assign) NSInteger trackTimeMillis;

/// 高解像度アートワーク URL（100x100 を 600x600 に差し替え）。
@property (nonatomic, copy, readonly, nullable) NSString *artworkUrlLarge;

/// リリース日を "yyyy-MM-dd" で返す（無ければ nil）。
@property (nonatomic, copy, readonly, nullable) NSString *releaseDateText;

/// 再生時間を "m:ss" で返す（無ければ nil）。
@property (nonatomic, copy, readonly, nullable) NSString *durationText;

/// iTunes Search API の 1 要素（辞書）から生成する。
+ (nullable instancetype)fromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
