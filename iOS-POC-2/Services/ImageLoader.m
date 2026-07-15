#import "ImageLoader.h"

@interface ImageLoader ()
@property (nonatomic, strong) NSCache<NSString *, UIImage *> *cache;
@end

@implementation ImageLoader

+ (instancetype)sharedLoader {
    static ImageLoader *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ImageLoader alloc] init];
    });
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cache = [[NSCache alloc] init];
    }
    return self;
}

- (void)loadImageFromURLString:(NSString *)urlString
                    completion:(void (^)(UIImage *_Nullable))completion {
    if (!completion) {
        return;
    }
    if (urlString.length == 0) {
        completion(nil);
        return;
    }

    UIImage *cached = [self.cache objectForKey:urlString];
    if (cached) {
        completion(cached);
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        completion(nil);
        return;
    }

    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *task =
        [[NSURLSession sharedSession] dataTaskWithURL:url
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
        UIImage *image = data ? [UIImage imageWithData:data] : nil;
        if (image) {
            [weakSelf.cache setObject:image forKey:urlString];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(image);
        });
    }];
    [task resume];
}

@end
