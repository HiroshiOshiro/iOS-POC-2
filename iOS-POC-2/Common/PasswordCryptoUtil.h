#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// パスワードの暗号化（ハッシュ化）を行う Objective-C の Util。
/// 通信前にパスワードをそのまま送らないためのサンプル実装。
@interface PasswordCryptoUtil : NSObject

/// 入力文字列の SHA-256 ハッシュを 16 進数文字列で返す。
/// 入力が nil の場合は nil を返す。
+ (nullable NSString *)sha256HexOfString:(nullable NSString *)input;

@end

NS_ASSUME_NONNULL_END
