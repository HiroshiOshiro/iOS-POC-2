import Testing
import Foundation
import FactoryKit
import Model
import Network
import Database
@testable import Data

// @Injected は Container.shared から解決するため、スタブは register で差し替える。
// 共有コンテナを使うので直列実行にして register の競合を避ける。
@Suite(.serialized)
struct DefaultTodoRepositoryTests {

    @Test("Given submit succeeds, when submit is called, then the new record is saved at the top")
    func savesNewRecordPrepended() async throws {
        let remote = StubTodoRemote()
        let local = StubTodoLocal(
            records: [TodoRecord(text: "old", createdAt: Date(timeIntervalSince1970: 0))]
        )
        Container.shared.todoRemoteDataSource.register { remote }
        Container.shared.todoLocalDataSource.register { local }
        let sut = DefaultTodoRepository()

        try await sut.submit(Todo(text: "new"))

        #expect(remote.submittedTexts == ["new"])
        #expect(local.records.count == 2)
        #expect(local.records.first?.text == "new") // 新しい順で先頭へ
    }

    @Test("Given the remote fails, when submit is called, then it throws and nothing is saved")
    func doesNotSaveWhenRemoteFails() async {
        let remote = StubTodoRemote(shouldThrow: true)
        let local = StubTodoLocal()
        Container.shared.todoRemoteDataSource.register { remote }
        Container.shared.todoLocalDataSource.register { local }
        let sut = DefaultTodoRepository()

        await #expect(throws: TodoRemoteError.self) {
            try await sut.submit(Todo(text: "x"))
        }
        #expect(local.records.isEmpty)
    }
}
