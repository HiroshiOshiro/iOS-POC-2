#import "FakeAPIClient.h"

@implementation FakeAPIClient

+ (instancetype)sharedClient {
    static FakeAPIClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[FakeAPIClient alloc] init];
    });
    return shared;
}

- (void)submitTodoText:(NSString *)text
            completion:(void (^)(BOOL success))completion {
    // ネットワーク遅延を模して 1 秒後に成功を返す。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (completion) {
            completion(YES);
        }
    });
}

@end
