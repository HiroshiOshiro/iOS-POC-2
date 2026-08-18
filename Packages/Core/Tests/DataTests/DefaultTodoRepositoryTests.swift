import Testing
import Foundation
import Model
import Networking
import Database
@testable import Data

// コンストラクタへスタブを直接渡すため、Container には一切触れない。
struct DefaultTodoRepositoryTests {

    @Test("Given submit succeeds, when submit is called, then the new record is saved at the top")
    func savesNewRecordPrepended() async throws {
        let remote = StubTodoRemote()
        let local = StubTodoLocal(
            records: [TodoRecord(text: "old", createdAt: Date(timeIntervalSince1970: 0))]
        )
        let sut = DefaultTodoRepository(remote: remote, local: local)

        try await sut.submit(Todo(text: "new"))

        #expect(remote.submittedTexts == ["new"])
        #expect(local.records.count == 2)
        #expect(local.records.first?.text == "new") // 新しい順で先頭へ
    }

    @Test("Given the remote fails, when submit is called, then it throws and nothing is saved")
    func doesNotSaveWhenRemoteFails() async {
        let remote = StubTodoRemote(shouldThrow: true)
        let local = StubTodoLocal()
        let sut = DefaultTodoRepository(remote: remote, local: local)

        await #expect(throws: TodoRemoteError.self) {
            try await sut.submit(Todo(text: "x"))
        }
        #expect(local.records.isEmpty)
    }
}
