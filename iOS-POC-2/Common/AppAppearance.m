#import "AppAppearance.h"

@implementation AppAppearance

+ (UIColor *)brandColor {
    // ブランドカラー（インディゴ系）。main バンドルの Color Set "Brand"（ライト/ダーク対応）を参照。
    // Swift 側は DesignSystem モジュールの同名 Color Set を Color.brand で引く（別バンドルのため各1個）。
    return [UIColor colorNamed:@"Brand"];
}

@end
