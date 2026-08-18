import FactoryKit
import Networking
import Database
import Datastore

/// Data 層が提供する依存の登録。
/// リポジトリはデータソースへのアクセスを直列化する actor のため、アプリ全体で 1 インスタンスを共有する。
/// 依存（データソース等）はここでコンテナから解決し、コンストラクタへ渡す。
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
                userIDStorage: self.userIDStorage(),
                tokenManager: self.tokenManager()
            )
        }.singleton
    }

    var musicRepository: Factory<any MusicRepository> {
        self {
            DefaultMusicRepository(
                remote: self.musicRemoteDataSource(),
                networkMonitor: self.networkMonitor()
            )
        }
    }
}
