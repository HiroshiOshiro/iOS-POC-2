import UIKit

/// VC を実ウィンドウに載せて `viewWillAppear`/`onAppear` を発火させ、非同期ロードが落ち着くまで待つ。
///
/// `Packages/Feature/Tests/FeatureSnapshotTests`（Login/Music/Confirm）と
/// `iOS-POC-2Tests`（Todo）の両方のスナップショットテストから使う共通ヘルパー。
@MainActor
public func hostAndSettle(_ vc: UIViewController, seconds: Double = 0.8) async {
    let frame = CGRect(x: 0, y: 0, width: 390, height: 844)
    let window: UIWindow
    if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
        // 接続済みシーンがあれば非推奨でない方の初期化子を使う（`iOS-POC-2Tests` はアプリ本体
        // ホストなので常にこちらに入る）。
        window = UIWindow(windowScene: scene)
        window.frame = frame
    } else {
        // `FeatureSnapshotTests`（SPM パッケージのテストターゲット）は素の `xctest` プロセスで
        // 動き、接続済みシーンを持たない。`UIWindow(windowScene:)` は使えないため、非推奨の
        // `UIWindow(frame:)` にフォールバックする（iOS 26 で非推奨。シーン無しでウィンドウを
        // 作る非推奨でない代替 API は無いため、この1箇所の警告は意図的に許容している）。
        window = makeLegacyWindow(frame: frame)
    }
    window.rootViewController = vc
    window.makeKeyAndVisible()
    vc.view.setNeedsLayout()
    vc.view.layoutIfNeeded()
    try? await Task.sleep(for: .seconds(seconds))
}

@available(iOS, deprecated: 26.0, message: "Only used when no UIWindowScene is connected (e.g. a plain xctest host for an SPM package test target); there is no non-deprecated way to create a UIWindow in that case.")
private func makeLegacyWindow(frame: CGRect) -> UIWindow {
    UIWindow(frame: frame)
}
