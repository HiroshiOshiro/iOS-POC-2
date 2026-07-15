#import "ITunesAPIClient.h"

static NSString *const kBaseURL = @"https://itunes.apple.com/search";

@implementation ITunesAPIClient

+ (instancetype)sharedClient {
    static ITunesAPIClient *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[ITunesAPIClient alloc] init];
    });
    return shared;
}

- (void)searchTracksWithTerm:(NSString *)term
                  completion:(void (^)(NSArray<Track *> *_Nullable, NSError *_Nullable))completion {
    NSURLComponents *components = [NSURLComponents componentsWithString:kBaseURL];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"term" value:term],
        [NSURLQueryItem queryItemWithName:@"country" value:@"JP"],
        [NSURLQueryItem queryItemWithName:@"lang" value:@"ja_jp"],
        [NSURLQueryItem queryItemWithName:@"media" value:@"music"],
        [NSURLQueryItem queryItemWithName:@"entity" value:@"song"],
        [NSURLQueryItem queryItemWithName:@"limit" value:@"50"],
    ];

    NSURL *url = components.URL;
    if (!url) {
        [self callCompletion:completion
                      tracks:nil
                       error:[self errorWithMessage:NSLocalizedString(@"api.error.invalid_url", nil)]];
        return;
    }

    [self logRequestWithURL:url];
    NSDate *startedAt = [NSDate date];

    NSURLSessionDataTask *task =
        [[NSURLSession sharedSession] dataTaskWithURL:url
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
        [self logResponse:response data:data error:error startedAt:startedAt];
        if (error) {
            [self callCompletion:completion tracks:nil error:error];
            return;
        }
        NSError *jsonError = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data ?: [NSData data]
                                                            options:0
                                                              error:&jsonError];
        if (jsonError || ![json isKindOfClass:[NSDictionary class]]) {
            [self callCompletion:completion
                          tracks:nil
                           error:jsonError ?: [self errorWithMessage:NSLocalizedString(@"api.error.parse_failed", nil)]];
            return;
        }

        NSMutableArray<Track *> *tracks = [NSMutableArray array];
        NSArray *results = json[@"results"];
        if ([results isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in results) {
                Track *track = [Track fromDictionary:dict];
                if (track) {
                    [tracks addObject:track];
                }
            }
        }
        [self callCompletion:completion tracks:[tracks copy] error:nil];
    }];
    [task resume];
}

#pragma mark - Helpers

- (void)callCompletion:(void (^)(NSArray<Track *> *_Nullable, NSError *_Nullable))completion
                tracks:(NSArray<Track *> *)tracks
                 error:(NSError *)error {
    if (!completion) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(tracks, error);
    });
}

#pragma mark - Logging

// リクエスト/レスポンスの内容をコンソールに出力する（DEBUG ビルドのみ）。
- (void)logRequestWithURL:(NSURL *)url {
#if DEBUG
    NSLog(@"[iTunes API] ▶ Request  GET %@", url.absoluteString);
#endif
}

- (void)logResponse:(NSURLResponse *)response
               data:(NSData *)data
              error:(NSError *)error
          startedAt:(NSDate *)startedAt {
#if DEBUG
    NSTimeInterval elapsedMs = [[NSDate date] timeIntervalSinceDate:startedAt] * 1000.0;
    if (error) {
        NSLog(@"[iTunes API] ◀ Response ERROR (%.0f ms): %@", elapsedMs, error.localizedDescription);
        return;
    }
    NSInteger statusCode = 0;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        statusCode = ((NSHTTPURLResponse *)response).statusCode;
    }
    NSString *body = data.length > 0
                         ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                         : @"";
    // ボディが大きいので先頭のみ出力する。
    const NSUInteger maxLength = 2000;
    NSString *truncated = body.length > maxLength
                              ? [[body substringToIndex:maxLength] stringByAppendingString:@" …(truncated)"]
                              : body;
    NSLog(@"[iTunes API] ◀ Response %ld (%.0f ms, %lu bytes)\n%@",
          (long)statusCode, elapsedMs, (unsigned long)data.length, truncated);
#endif
}

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"ITunesAPIClient"
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
