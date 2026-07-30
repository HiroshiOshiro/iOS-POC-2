import FactoryKit

/// Data 層が提供する依存の登録。
/// リポジトリはデータソースへのアクセスを直列化する actor のため、アプリ全体で 1 インスタンスを共有する。
/// データソースはリポジトリ側が `@Injected` でコンテナから直接解決するため、ここでは生成のみ。
/// NiA 相当: core:data の di（Hilt の `DataModule`）。
public extension Container {

    var todoRepository: Factory<any TodoRepository> {
        self { DefaultTodoRepository() }.singleton
    }

    var authRepository: Factory<any AuthRepository> {
        self { DefaultAuthRepository() }.singleton
    }

    var musicRepository: Factory<any MusicRepository> {
        self { DefaultMusicRepository() }
    }
}
