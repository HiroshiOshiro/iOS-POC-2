import FactoryKit

/// Network 層が提供する依存の登録。
/// リモートデータソースの実装をここで登録し、上位（Data 層）はコンテナから解決する。
/// NiA 相当: core:network の di（Hilt の `NetworkModule`）。
public extension Container {

    var authRemoteDataSource: Factory<any AuthRemoteDataSource> {
        self { FakeAuthRemoteDataSource() }
    }

    var todoRemoteDataSource: Factory<any TodoRemoteDataSource> {
        self { FakeTodoRemoteDataSource() }
    }
}
