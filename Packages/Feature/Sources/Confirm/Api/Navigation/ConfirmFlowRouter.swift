import Foundation

/// 確認フローから「Feature の外」への遷移を依頼する窓口。
/// 実装はアプリ側（Coordinator）が担うため、Feature は ObjC 側を一切知らない。
/// NiA 相当の位置: feature:*:api の navigation（`TopicNavKey`）。ただし機構は
/// Coordinator へのコールバックで、NiA の NavKey（route + パラメータ）とは異なる。
@MainActor
public protocol ConfirmFlowRouter: AnyObject {
    /// 保存が完了したので完了画面へ進む。
    func navigateToComplete()
    /// 確認フローを抜けて入力画面へ戻る。
    func navigateBack()
}
