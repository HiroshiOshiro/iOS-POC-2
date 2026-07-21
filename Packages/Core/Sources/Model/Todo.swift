import Foundation

/// Todo 1 件を表すドメインモデル。
/// NiA 相当: core:model のモデル（`Topic` / `NewsResource`）。
public struct Todo: Sendable, Equatable {
    public let text: String
    public let createdAt: Date

    public init(text: String, createdAt: Date = Date()) {
        self.text = text
        self.createdAt = createdAt
    }
}
