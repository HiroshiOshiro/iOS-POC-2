import Foundation

/// Todo の永続化を抽象化したリポジトリ。実装は Data 層が提供する。
public protocol TodoRepository: Sendable {
    /// Todo を送信（フェイク API）し、ローカルへ保存する。
    func submit(_ todo: Todo) async
}
