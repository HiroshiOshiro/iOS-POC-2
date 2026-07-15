#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Todo 1 件を表すモデル。
@interface TodoItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;

- (instancetype)initWithText:(NSString *)text createdAt:(NSDate *)createdAt;

/// NSUserDefaults 保存用に辞書へ変換する。
- (NSDictionary *)toDictionary;

/// 辞書から復元する。
+ (nullable instancetype)fromDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
