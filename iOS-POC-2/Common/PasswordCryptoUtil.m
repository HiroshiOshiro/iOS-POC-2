#import "PasswordCryptoUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation PasswordCryptoUtil

+ (nullable NSString *)sha256HexOfString:(nullable NSString *)input {
    if (input == nil) {
        return nil;
    }

    // Swift 側から interface 経由で呼ばれ、ObjC がハッシュ化を実行したことを確認するためのログ。
    NSLog(@"[PasswordCryptoUtil] SHA-256 hashing (ObjC)");

    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);

    NSMutableString *hex = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hex appendFormat:@"%02x", digest[i]];
    }
    return hex;
}

@end
