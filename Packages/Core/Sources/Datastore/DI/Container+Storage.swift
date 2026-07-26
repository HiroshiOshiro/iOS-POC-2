import FactoryKit

/// Datastore 層が提供する依存の登録。
/// 設定値・秘匿情報のストレージ実装をここで登録し、上位（Data 層）はコンテナから解決する。
/// NiA 相当: core:datastore の di（Hilt の `DataStoreModule`）。
public extension Container {

    var emailStorage: Factory<any EmailStorage> {
        self { UserDefaultsEmailStorage(key: StorageKeys.loginEmail) }
    }

    var userIDStorage: Factory<any UserIDStorage> {
        self { KeychainUserIDStorage() }
    }
}
