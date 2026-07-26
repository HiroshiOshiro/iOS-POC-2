import Foundation

/// ViewModel の保存/ログインは `Task { }` で非同期に走るため、条件が満たされるまで
/// 協調的に待つ小さなヘルパー（iOS 15 対応のため Duration/Clock は使わない）。
@MainActor
func waitUntil(_ condition: () -> Bool, maxYields: Int = 10_000) async {
    var count = 0
    while !condition() && count < maxYields {
        await Task.yield()
        count += 1
    }
}

/// スタブ用の汎用エラー。
enum StubError: Error { case failed }
