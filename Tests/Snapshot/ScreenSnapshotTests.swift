import Testing
import SnapshotTesting
import SwiftUI
import UIKit
import FactoryKit
import Model
import Domain
import LoginImpl
import MusicImpl
import ConfirmApi
@testable import ConfirmImpl

/// 主要画面の見た目をスナップショット（基準 PNG）で固定し、レイアウト/テーマの回帰を検知する。
///
/// - 撮影対象は公開窓口 `*ScreenFactory` が返す `UIViewController`（内部 View は非公開のため）。
/// - 各画面の `#Preview` と同じ要領で、`Container.shared` にスタブ UseCase を登録して
///   オフライン・固定内容にする（実通信・Keychain を避け決定論にする）。
/// - `Container.shared` はグローバルなため、登録の相互干渉を避けて `.serialized` で直列実行する。
/// - 端末サイズ非依存にするため固定 `ViewImageConfig`（`.iPhone13`）で撮る。微小なレンダ差は
///   `perceptualPrecision` で吸収する。**基準画像は CI と同じシミュレータ/OS で記録すること。**
@MainActor
@Suite(.serialized)
struct ScreenSnapshotTests {

    /// 固定 config（レイアウトを実機サイズに依存させない）と許容誤差。
    private let config: ViewImageConfig = .iPhone13
    private let perceptualPrecision: Float = 0.98

    // MARK: - Login

    @Test("Login screen — default (light / dark)")
    func loginScreen() {
        Container.shared.loginUseCase.register { StubLoginUseCase() }
        Container.shared.loadSessionUseCase.register { StubLoadSessionUseCase() }

        let vc = LoginScreenFactory.makeLoginScreen()

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

    // MARK: - Music

    @Test("Music list — populated (light / dark)")
    func musicListScreen() async {
        Container.shared.searchMusicUseCase.register {
            StubSearchMusicUseCase(tracks: Self.sampleTracks)
        }

        let vc = MusicScreenFactory.makeMusicScreen()
        // onAppear の非同期検索（スタブは即時）を完了させてから撮る。
        await hostAndSettle(vc)

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

    // MARK: - Confirm（内部 View を @testable で直接生成。init で state を注入）

    @Test("Confirm1 — default (light / dark)")
    func confirm1Screen() {
        let vc = UIHostingController(
            rootView: Confirm1View(text: "牛乳を買う", router: StubConfirmRouter(), onNext: {})
        )
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

    @Test("Confirm2 — default (light / dark)")
    func confirm2Screen() {
        Container.shared.submitTodoUseCase.register { StubSubmitTodoUseCase() }

        let vc = UIHostingController(
            rootView: Confirm2View(text: "牛乳を買う", router: StubConfirmRouter(), onBack: {})
        )
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

    // MARK: - Helpers

    /// VC を実ウィンドウに載せて `onAppear` を発火させ、非同期ロードが落ち着くまで待つ。
    private func hostAndSettle(_ vc: UIViewController, seconds: Double = 0.8) async {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.view.setNeedsLayout()
        vc.view.layoutIfNeeded()
        try? await Task.sleep(for: .seconds(seconds))
    }

    /// artworkUrl100 は nil（AsyncImage を確実にプレースホルダにして決定論化）。
    private static let sampleTracks: [MusicTrack] = [
        track(id: 1, name: "Lemon", artist: "米津玄師"),
        track(id: 2, name: "Pretender", artist: "Official髭男dism"),
        track(id: 3, name: "夜に駆ける", artist: "YOASOBI"),
    ]

    private static func track(id: Int, name: String, artist: String) -> MusicTrack {
        MusicTrack(
            id: id, trackName: name, artistName: artist,
            collectionName: nil, primaryGenreName: nil, artworkUrl100: nil,
            previewUrl: nil, trackViewUrl: nil, releaseDate: nil, trackTimeMillis: 0
        )
    }
}

// MARK: - Stub UseCases

private struct StubLoginUseCase: LoginUseCase {
    func execute(email: String, password: String) async throws -> Session {
        Session(email: email, userID: "user-preview")
    }
}

private struct StubLoadSessionUseCase: LoadSessionUseCase {
    func execute() async -> Session? { nil }
}

private struct StubSearchMusicUseCase: SearchMusicUseCase {
    let tracks: [MusicTrack]
    func execute(term: String) async throws -> [MusicTrack] { tracks }
}

private struct StubSubmitTodoUseCase: SubmitTodoUseCase {
    func execute(text: String) async throws {}
}

/// 遷移を伴わない no-op Router（撮影は既定表示のみのため何もしない）。
@MainActor
private final class StubConfirmRouter: ConfirmFlowRouter {
    func navigateToComplete() {}
    func navigateBack() {}
}
