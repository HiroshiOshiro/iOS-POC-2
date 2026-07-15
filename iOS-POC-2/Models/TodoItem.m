#import "TodoItem.h"

static NSString *const kTextKey = @"text";
static NSString *const kCreatedAtKey = @"createdAt";

@implementation TodoItem

- (instancetype)initWithText:(NSString *)text createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        _text = [text copy];
        _createdAt = createdAt;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    return @{
        kTextKey: self.text ?: @"",
        kCreatedAtKey: self.createdAt ?: [NSDate date],
    };
}

+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    NSString *text = dictionary[kTextKey];
    NSDate *createdAt = dictionary[kCreatedAtKey];
    if (![text isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (![createdAt isKindOfClass:[NSDate class]]) {
        createdAt = [NSDate date];
    }
    return [[TodoItem alloc] initWithText:text createdAt:createdAt];
}

@end
