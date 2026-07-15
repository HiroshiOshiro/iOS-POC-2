#import "Track.h"

@implementation Track

+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    Track *track = [[Track alloc] init];
    track.trackId = [dictionary[@"trackId"] isKindOfClass:[NSNumber class]]
                        ? [dictionary[@"trackId"] integerValue] : 0;
    track.trackName = [self stringForKey:@"trackName" in:dictionary];
    track.artistName = [self stringForKey:@"artistName" in:dictionary];
    track.collectionName = [self stringForKey:@"collectionName" in:dictionary];
    track.primaryGenreName = [self stringForKey:@"primaryGenreName" in:dictionary];
    track.artworkUrl100 = [self stringForKey:@"artworkUrl100" in:dictionary];
    track.previewUrl = [self stringForKey:@"previewUrl" in:dictionary];
    track.trackViewUrl = [self stringForKey:@"trackViewUrl" in:dictionary];
    track.releaseDate = [self stringForKey:@"releaseDate" in:dictionary];
    track.trackTimeMillis = [dictionary[@"trackTimeMillis"] isKindOfClass:[NSNumber class]]
                                ? [dictionary[@"trackTimeMillis"] integerValue] : 0;
    return track;
}

+ (nullable NSString *)stringForKey:(NSString *)key in:(NSDictionary *)dictionary {
    id value = dictionary[key];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

- (nullable NSString *)artworkUrlLarge {
    if (self.artworkUrl100.length == 0) {
        return nil;
    }
    return [self.artworkUrl100 stringByReplacingOccurrencesOfString:@"100x100"
                                                         withString:@"600x600"];
}

- (nullable NSString *)releaseDateText {
    if (self.releaseDate.length < 10) {
        return nil;
    }
    return [self.releaseDate substringToIndex:10];
}

- (nullable NSString *)durationText {
    if (self.trackTimeMillis <= 0) {
        return nil;
    }
    NSInteger totalSeconds = self.trackTimeMillis / 1000;
    NSInteger minutes = totalSeconds / 60;
    NSInteger seconds = totalSeconds % 60;
    return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

@end
