#import <Foundation/Foundation.h>
#import "TodoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// Todo の永続化を担当するストア。
/// Android の SharedPreference に相当する NSUserDefaults を利用する。
///
/// 追加（保存）は Swift の Data/LocalStorage 層が担うため、ここでは読み取りと削除のみ提供する。
@interface TodoStore : NSObject

+ (instancetype)sharedStore;

/// 保存済みの全 Todo を新しい順で返す。
- (NSArray<TodoItem *> *)allItems;

/// 指定インデックスの Todo を削除して保存する。
- (void)removeItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
