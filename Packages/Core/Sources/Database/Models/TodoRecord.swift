import Foundation

/// ローカルに保存する Todo のレコード（永続化フォーマットに対応する DTO）。
/// 他層に依存しないよう、Data 層のモデルとは分けて定義する（変換は Data 層が行う）。
/// NiA 相当: core:database の Entity（`TopicEntity` / `NewsResourceEntity`）。
public struct TodoRecord: Sendable, Equatable {
    public let text: String
    public let createdAt: Date

    public init(text: String, createdAt: Date) {
        self.text = text
        self.createdAt = createdAt
    }
}
