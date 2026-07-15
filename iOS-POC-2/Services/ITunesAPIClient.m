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
        [self callCompletion:completion tracks:nil error:[self errorWithMessage:@"URL の生成に失敗しました"]];
        return;
    }

    NSURLSessionDataTask *task =
        [[NSURLSession sharedSession] dataTaskWithURL:url
                                    completionHandler:^(NSData *data,
                                                        NSURLResponse *response,
                                                        NSError *error) {
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
                           error:jsonError ?: [self errorWithMessage:@"レスポンスの解析に失敗しました"]];
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

- (NSError *)errorWithMessage:(NSString *)message {
    return [NSError errorWithDomain:@"ITunesAPIClient"
                               code:-1
                           userInfo:@{NSLocalizedDescriptionKey: message}];
}

@end
