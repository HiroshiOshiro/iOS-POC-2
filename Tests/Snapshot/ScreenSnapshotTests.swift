import Testing
import SnapshotTestingSupport
import SnapshotTestHelpers
import UIKit

/// ObjC/UIKit の Todo 画面（アプリ本体ターゲットにしか無いコード）のスナップショット。
///
/// `TodoInputViewController` は SPM パッケージ化されていないため、パッケージ側のテスト
/// （`Packages/Feature/Tests/FeatureSnapshotTests`）からは到達できない。Login/Music/Confirm
/// のようにパッケージ内へ実装が移った画面は、そちら側のスナップショットテストへ移動済み。
/// - 端末サイズ非依存にするため固定 `ViewImageConfig`（`.iPhone13`）で撮る。微小なレンダ差は
///   `perceptualPrecision` で吸収する。**基準画像は CI と同じシミュレータ/OS で記録すること。**
@MainActor
struct ScreenSnapshotTests {

    /// 固定 config（レイアウトを実機サイズに依存させない）と許容誤差。
    private let config: ViewImageConfig = .iPhone13
    private let perceptualPrecision: Float = 0.98

    // MARK: - Todo（ObjC/UIKit・未移行画面。ブリッジヘッダ経由で参照）

    @Test("Todo input — empty (light / dark)")
    func todoInputScreenEmpty() async {
        // TodoStore は NSUserDefaults(standard) のキー todo_items を読む。空状態に固定する。
        UserDefaults.standard.removeObject(forKey: "todo_items")

        let vc = TodoInputViewController()
        await hostAndSettle(vc) // viewWillAppear→reloadItems を発火させる

        assertSnapshot(
            of: vc,
            as: .image(on: config, perceptualPrecision: perceptualPrecision,
                       traits: .init(userInterfaceStyle: .light)),
            named: "light"
        )
        assertSnapshot(
            of: vc,
            as: .image(on: config, perceptualPrecision: perceptualPrecision,
                       traits: .init(userInterfaceStyle: .dark)),
            named: "dark"
        )
    }
}
