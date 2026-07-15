#import "TodoStore.h"

static NSString *const kTodoItemsKey = @"todo_items";

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
    // 他レイヤー（Swift の LocalStorage）からの書き込みも反映するため毎回読み直す。
    [self load];
    return [self.items copy];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    // 表示中の一覧（allItems で読み直した内容）と索引を合わせるため読み直す。
    [self load];
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
