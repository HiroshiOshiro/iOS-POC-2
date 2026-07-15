#import <UIKit/UIKit.h>
#import "Track.h"

NS_ASSUME_NONNULL_BEGIN

/// 楽曲の詳細画面。アートワーク・情報を表示し、30秒試聴と iTunes ページ表示ができる。
@interface MusicDetailViewController : UIViewController

- (instancetype)initWithTrack:(Track *)track;

@end

NS_ASSUME_NONNULL_END
