import Testing
import Foundation
@testable import Datastore

/// Keychain は entitlement を要するため、このテストはホストアプリ（iOS-POC-2）を
/// テストホストにした app ホストのユニットテストとして実行する（Core の純 SPM テストにはできない）。
/// フレームワークは他テストと揃えて Swift Testing を使用。
///
/// Swift Testing はテストごとに新インスタンスを生成するため、`init` で固有のサービス名を用意し、
/// `deinit` で必ず purge して他テストや実アプリの Keychain 項目と干渉させない。
final class KeyChainUtilTests {

    private let serviceName = "iOS-POC-2.KeyChainUtilTests.\(UUID().uuidString)"
    private let username = "test-account"

    deinit {
        try? KeyChainUtil.purge(serviceName: serviceName)
    }

    // MARK: - get

    @Test("Given no saved value, when get, then it returns nil")
    func getReturnsNilWhenEmpty() throws {
        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == nil)
    }

    // MARK: - save

    @Test("Given no saved value, when save, then get returns the saved value")
    func saveThenGetReturnsValue() throws {
        try KeyChainUtil.save("user-123", username: username, serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "user-123")
    }

    @Test("Given an existing value, when save a different value, then it is overwritten")
    func saveOverwritesExistingValue() throws {
        try KeyChainUtil.save("old-value", username: username, serviceName: serviceName)

        try KeyChainUtil.save("new-value", username: username, serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "new-value")
    }

    @Test("Given an existing value, when save the same value, then it returns true and is unchanged")
    func saveSameValueReturnsTrue() throws {
        try KeyChainUtil.save("same-value", username: username, serviceName: serviceName)

        let result = try KeyChainUtil.save("same-value", username: username, serviceName: serviceName)

        #expect(result)
        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "same-value")
    }

    @Test("Given an existing value, when save with updateExisting false, then it returns false and is unchanged")
    func saveWithoutUpdateReturnsFalse() throws {
        try KeyChainUtil.save("old-value", username: username, serviceName: serviceName)

        let result = try KeyChainUtil.save(
            "new-value",
            username: username,
            serviceName: serviceName,
            updateExisting: false
        )

        #expect(result == false)
        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "old-value")
    }

    @Test("Given an empty string, when save, then get returns an empty string")
    func saveEmptyString() throws {
        try KeyChainUtil.save("", username: username, serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "")
    }

    @Test("Given a multibyte string, when save, then get returns the same string")
    func saveMultibyteString() throws {
        try KeyChainUtil.save("ユーザー🔑", username: username, serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "ユーザー🔑")
    }

    // MARK: - Isolation

    @Test("Given the same service, when save for different usernames, then values are isolated")
    func valuesIsolatedByUsername() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: "account-a", serviceName: serviceName) == "value-a")
        #expect(try KeyChainUtil.get(username: "account-b", serviceName: serviceName) == "value-b")
    }

    @Test("Given the same username, when save for different services, then values are isolated")
    func valuesIsolatedByService() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeyChainUtil.purge(serviceName: otherService) }

        try KeyChainUtil.save("value-1", username: username, serviceName: serviceName)
        try KeyChainUtil.save("value-2", username: username, serviceName: otherService)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == "value-1")
        #expect(try KeyChainUtil.get(username: username, serviceName: otherService) == "value-2")
    }

    // MARK: - delete

    @Test("Given a saved value, when delete, then get returns nil")
    func deleteRemovesValue() throws {
        try KeyChainUtil.save("user-123", username: username, serviceName: serviceName)

        try KeyChainUtil.delete(username: username, serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == nil)
    }

    @Test("Given no saved value, when delete, then it succeeds")
    func deleteMissingValueSucceeds() throws {
        #expect(try KeyChainUtil.delete(username: username, serviceName: serviceName))
    }

    @Test("Given multiple usernames in the same service, when delete one, then the others remain")
    func deleteOneKeepsOthers() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        try KeyChainUtil.delete(username: "account-a", serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: "account-a", serviceName: serviceName) == nil)
        #expect(try KeyChainUtil.get(username: "account-b", serviceName: serviceName) == "value-b")
    }

    // MARK: - purge

    @Test("Given multiple items in a service, when purge, then all are removed")
    func purgeRemovesAll() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        try KeyChainUtil.purge(serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: "account-a", serviceName: serviceName) == nil)
        #expect(try KeyChainUtil.get(username: "account-b", serviceName: serviceName) == nil)
    }

    @Test("Given no saved items, when purge, then it succeeds")
    func purgeEmptyServiceSucceeds() throws {
        #expect(try KeyChainUtil.purge(serviceName: serviceName))
    }

    @Test("Given items in another service, when purge, then the other service is unaffected")
    func purgeDoesNotAffectOtherService() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeyChainUtil.purge(serviceName: otherService) }
        try KeyChainUtil.save("keep-me", username: username, serviceName: otherService)
        try KeyChainUtil.save("purge-me", username: username, serviceName: serviceName)

        try KeyChainUtil.purge(serviceName: serviceName)

        #expect(try KeyChainUtil.get(username: username, serviceName: serviceName) == nil)
        #expect(try KeyChainUtil.get(username: username, serviceName: otherService) == "keep-me")
    }
}
