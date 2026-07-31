#import "AppAppearance.h"

@implementation AppAppearance

+ (UIColor *)navBarColor {
    // ナビゲーションバー背景色。main バンドルの Color Set "NavBar"（ライト/ダーク対応）を参照。
    // Swift 側は DesignSystem モジュールの同名 Color Set を Color.navBar で引く（別バンドルのため各1個）。
    return [UIColor colorNamed:@"NavBar"];
}

@end
