import FactoryKit

/// Data 層が提供する依存の登録。
/// リポジトリはデータソースへのアクセスを直列化する actor のため、アプリ全体で 1 インスタンスを共有する。
/// NiA 相当: core:data の di（Hilt の `DataModule`）。
public extension Container {

    var todoRepository: Factory<any TodoRepository> {
        self { DefaultTodoRepository() }.singleton
    }

    var authRepository: Factory<any AuthRepository> {
        // パスワード暗号化の実装（アプリ本体で ObjC 版に差し替えられる）は
        // ここで注入する。Repository 自身は DI コンテナを知らない。
        self { DefaultAuthRepository(passwordEncryptor: self.passwordEncryptor()) }.singleton
    }
}
