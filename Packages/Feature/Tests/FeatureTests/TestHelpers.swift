import Foundation

/// ViewModel の保存/ログインは `Task { }` で非同期に走るため、条件が満たされるまで
/// 一定間隔でポーリングして待つ小さなヘルパー（`ContinuousClock`/`Duration` を使用）。
@MainActor
func waitUntil(_ condition: () -> Bool, timeout: Duration = .seconds(2)) async {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() && clock.now < deadline {
        try? await Task.sleep(for: .milliseconds(5))
    }
}

/// スタブ用の汎用エラー。
enum StubError: Error { case failed }
