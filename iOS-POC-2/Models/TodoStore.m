#import "TodoStore.h"

static NSString *const kTodoItemsKey = @"todo_items";

NSNotificationName const TodoStoreDidAddItemNotification = @"TodoStoreDidAddItemNotification";

@interface TodoStore ()
@property (nonatomic, strong) NSMutableArray<TodoItem *> *items;
@end

@implementation TodoStore

+ (instancetype)sharedStore {
    static TodoStore *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[TodoStore alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

#pragma mark - Public

- (NSArray<TodoItem *> *)allItems {
    return [self.items copy];
}

- (void)addItem:(TodoItem *)item {
    // 新しい順で表示するため先頭へ挿入する。
    [self.items insertObject:item atIndex:0];
    [self persist];
    [[NSNotificationCenter defaultCenter] postNotificationName:TodoStoreDidAddItemNotification
                                                        object:self];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    if (index >= self.items.count) {
        return;
    }
    [self.items removeObjectAtIndex:index];
    [self persist];
}

#pragma mark - Persistence

- (void)load {
    self.items = [NSMutableArray array];
    NSArray *rawArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kTodoItemsKey];
    for (NSDictionary *dict in rawArray) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        TodoItem *item = [TodoItem fromDictionary:dict];
        if (item) {
            [self.items addObject:item];
        }
    }
}

- (void)persist {
    NSMutableArray *rawArray = [NSMutableArray arrayWithCapacity:self.items.count];
    for (TodoItem *item in self.items) {
        [rawArray addObject:[item toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:rawArray forKey:kTodoItemsKey];
}

@end
