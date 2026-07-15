#import <Foundation/Foundation.h>
#import "TodoItem.h"

NS_ASSUME_NONNULL_BEGIN

/// Todo が 1 件追加されたときに送られる通知。
extern NSNotificationName const TodoStoreDidAddItemNotification;

/// Todo の永続化を担当するストア。
/// Android の SharedPreference に相当する NSUserDefaults を利用する。
@interface TodoStore : NSObject

+ (instancetype)sharedStore;

/// 保存済みの全 Todo を新しい順で返す。
- (NSArray<TodoItem *> *)allItems;

/// Todo を 1 件追加して保存する。
- (void)addItem:(TodoItem *)item;

/// 指定インデックスの Todo を削除して保存する。
- (void)removeItemAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
