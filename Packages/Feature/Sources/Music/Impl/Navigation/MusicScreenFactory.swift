import UIKit
import SwiftUI

/// Music タブをアプリ（ObjC）へ公開する窓口。
/// タブに載せるため ObjC から生成できるよう `@objc` にし、返すのは `UIViewController` だけ。
/// 一覧→詳細の遷移は内部の `NavigationView` が担う。
/// NiA 相当: feature:*:impl の navigation の EntryProvider（`InterestsEntryProvider`）。
@MainActor
@objc public final class MusicScreenFactory: NSObject {

    @objc public static func makeMusicScreen() -> UIViewController {
        UIHostingController(rootView: MusicListView())
    }
}
