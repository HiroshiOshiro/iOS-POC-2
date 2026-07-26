import FactoryKit

/// Database 層が提供する依存の登録。
/// ローカルデータソースの実装をここで登録し、上位（Data 層）はコンテナから解決する。
/// NiA 相当: core:database の di（Hilt の `DatabaseModule`）。
public extension Container {

    var todoLocalDataSource: Factory<any TodoLocalDataSource> {
        self { UserDefaultsTodoDataSource() }
    }
}
