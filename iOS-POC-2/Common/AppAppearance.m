#import "AppAppearance.h"

@implementation AppAppearance

+ (UIColor *)navBarColor {
    // 役割（ナビバー背景）→ パレット（PaletteTeal）へのマップ。ObjC 側の意味的レイヤ。
    // 色そのものは main バンドルの Color Set "PaletteTeal"（ライト/ダーク対応）にある。
    // Swift 側は DesignSystem モジュールの同名パレットを Color.navBar で引く（別バンドルのため各1個）。
    return [UIColor colorNamed:@"PaletteTeal"];
}

@end
