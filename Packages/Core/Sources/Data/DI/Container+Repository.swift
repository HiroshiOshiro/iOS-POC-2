import FactoryKit
import Network
import Database
import Datastore

/// Data 層が提供する依存の登録。
/// リポジトリはデータソースへのアクセスを直列化する actor のため、アプリ全体で 1 インスタンスを共有する。
/// データソース（Network / Database / Datastore の登録）はコンテナから解決して注入する。
/// NiA 相当: core:data の di（Hilt の `DataModule`）。
public extension Container {

    var todoRepository: Factory<any TodoRepository> {
        self {
            DefaultTodoRepository(
                remote: self.todoRemoteDataSource(),
                local: self.todoLocalDataSource()
            )
        }.singleton
    }

    var authRepository: Factory<any AuthRepository> {
        self {
            DefaultAuthRepository(
                remote: self.authRemoteDataSource(),
                passwordEncryptor: self.passwordEncryptor(),
                emailStorage: self.emailStorage(),
                userIDStorage: self.userIDStorage()
            )
        }.singleton
    }

    var musicRepository: Factory<any MusicRepository> {
        self { DefaultMusicRepository(remote: self.musicRemoteDataSource()) }
    }
}
