import FactoryKit
import Data

/// Domain 層が提供する依存の登録。
/// リポジトリは Data 層の登録（`Container.todoRepository` など）を解決して注入する。
/// UseCase は軽量な値型のため既定のスコープ（unique）で都度生成する。
/// NiA 相当: core:domain の di（Hilt モジュール）。
public extension Container {

    var submitTodoUseCase: Factory<any SubmitTodoUseCase> {
        self { DefaultSubmitTodoUseCase(repository: self.todoRepository()) }
    }

    var loginUseCase: Factory<any LoginUseCase> {
        self { DefaultLoginUseCase(repository: self.authRepository()) }
    }

    var loadSessionUseCase: Factory<any LoadSessionUseCase> {
        self { DefaultLoadSessionUseCase(repository: self.authRepository()) }
    }
}
