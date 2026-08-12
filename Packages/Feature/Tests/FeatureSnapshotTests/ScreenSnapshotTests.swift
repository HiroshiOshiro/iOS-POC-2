import Testing
import SnapshotTestingSupport
import SnapshotTestHelpers
import SwiftUI
import UIKit
import FactoryKit
import Model
import Domain
import Datastore
import LoginImpl
import MusicImpl
import ConfirmApi
@testable import ConfirmImpl

/// 主要画面の見た目をスナップショット（基準 PNG）で固定し、レイアウト/テーマの回帰を検知する。
///
/// - 撮影対象は公開窓口 `*ScreenFactory` が返す `UIViewController`（内部 View は非公開のため）、
///   または `@testable import` で直接生成する内部 SwiftUI View。
/// - 各画面の `#Preview` と同じ要領で、`Container.shared` にスタブ UseCase を登録して
///   オフライン・固定内容にする（実通信・Keychain を避け決定論にする）。
/// - `Container.shared` はグローバルなため、登録の相互干渉を避けて `.serialized` で直列実行する。
/// - 端末サイズ非依存にするため固定 `ViewImageConfig`（`.iPhone13`）で撮る。微小なレンダ差は
///   `perceptualPrecision` で吸収する。**基準画像は CI と同じシミュレータ/OS で記録すること。**
///
/// ObjC/UIKit の Todo 画面（アプリ本体ターゲット側にしか無いコード）だけは、ここから
/// 到達できないため対象外（そちらは `iOS-POC-2Tests` 側の `ScreenSnapshotTests` を参照）。
@MainActor
@Suite(.serialized)
struct ScreenSnapshotTests {

    /// 固定 config（レイアウトを実機サイズに依存させない）と許容誤差。
    private let config: ViewImageConfig = .iPhone13
    private let perceptualPrecision: Float = 0.98

    // MARK: - Login

    @Test("Login screen — default (light / dark)")
    func loginScreen() {
        // 保存メールを消し、セッション無し（＝保存済みブロック非表示）の既定状態に固定する。
        UserDefaults.standard.removeObject(forKey: StorageKeys.loginEmail)
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

    @Test("Login screen — session restored (light / dark)")
    func loginScreenSessionRestored() async {
        // 保存済みメール＋復元セッションあり → 画面下部に「保存済み」ブロックが出る状態。
        UserDefaults.standard.set("user@example.com", forKey: StorageKeys.loginEmail)
        Container.shared.loginUseCase.register { StubLoginUseCase() }
        Container.shared.loadSessionUseCase.register {
            StubLoadSessionUseCase(session: Session(email: "user@example.com", userID: "user-1"))
        }

        let vc = LoginScreenFactory.makeLoginScreen()
        await hostAndSettle(vc) // onAppear の loadSession を完了させ、保存済みブロックを表示させる

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

    @Test("Music list — empty / no results (light / dark)")
    func musicListScreenEmpty() async {
        // 検索が 0 件を返す → hasSearched=true かつ空 → 「該当なし」表示になる状態。
        Container.shared.searchMusicUseCase.register { StubSearchMusicUseCase(tracks: []) }

        let vc = MusicScreenFactory.makeMusicScreen()
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

    // MARK: - Helpers

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
    var session: Session? = nil
    func execute() async -> Session? { session }
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
