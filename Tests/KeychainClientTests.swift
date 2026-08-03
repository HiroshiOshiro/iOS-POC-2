import Testing
import Foundation
import Security
@testable import Datastore

/// Keychain は entitlement を要するため、このテストはホストアプリ（iOS-POC-2）を
/// テストホストにした app ホストのユニットテストとして実行する（Core の純 SPM テストにはできない）。
/// フレームワークは他テストと揃えて Swift Testing を使用。
///
/// Swift Testing はテストごとに新インスタンスを生成するため、`init` で固有のサービス名を用意し、
/// `deinit` で必ず purge して他テストや実アプリの Keychain 項目と干渉させない。
final class KeychainClientTests {

    private let serviceName = "iOS-POC-2.KeychainClientTests.\(UUID().uuidString)"
    private let username = "test-account"

    deinit {
        try? KeychainClient.purge(serviceName: serviceName)
    }

    // MARK: - get

    @Test("Given no saved value, when get, then it returns nil")
    func getReturnsNilWhenEmpty() throws {
        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == nil)
    }

    // MARK: - save

    @Test("Given no saved value, when save, then get returns the saved value")
    func saveThenGetReturnsValue() throws {
        try KeychainClient.save("user-123", username: username, serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "user-123")
    }

    @Test("Given an existing value, when save a different value, then it is overwritten")
    func saveOverwritesExistingValue() throws {
        try KeychainClient.save("old-value", username: username, serviceName: serviceName)

        try KeychainClient.save("new-value", username: username, serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "new-value")
    }

    @Test("Given an existing value, when save the same value, then it returns true and is unchanged")
    func saveSameValueReturnsTrue() throws {
        try KeychainClient.save("same-value", username: username, serviceName: serviceName)

        let result = try KeychainClient.save("same-value", username: username, serviceName: serviceName)

        #expect(result)
        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "same-value")
    }

    @Test("Given an existing value, when save with updateExisting false, then it returns false and is unchanged")
    func saveWithoutUpdateReturnsFalse() throws {
        try KeychainClient.save("old-value", username: username, serviceName: serviceName)

        let result = try KeychainClient.save(
            "new-value",
            username: username,
            serviceName: serviceName,
            updateExisting: false
        )

        #expect(result == false)
        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "old-value")
    }

    @Test("Given an empty string, when save, then get returns an empty string")
    func saveEmptyString() throws {
        try KeychainClient.save("", username: username, serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "")
    }

    @Test("Given a multibyte string, when save, then get returns the same string")
    func saveMultibyteString() throws {
        try KeychainClient.save("ユーザー🔑", username: username, serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "ユーザー🔑")
    }

    // MARK: - Accessibility（改善1: 端末外へ出さない設定の検証）

    @Test("Given a saved value, then the item's accessibility is AfterFirstUnlockThisDeviceOnly")
    func savedItemIsThisDeviceOnly() throws {
        try KeychainClient.save("user-123", username: username, serviceName: serviceName)

        // 保存項目の属性を読み出し、kSecAttrAccessible を確認する。
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        #expect(status == errSecSuccess)
        let attributes = result as? [String: Any]
        let accessible = attributes?[kSecAttrAccessible as String] as? String
        // バックアップ/他端末移行に含めない ThisDeviceOnly であること。
        #expect(accessible == (kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String))
    }

    // MARK: - Isolation

    @Test("Given the same service, when save for different usernames, then values are isolated")
    func valuesIsolatedByUsername() throws {
        try KeychainClient.save("value-a", username: "account-a", serviceName: serviceName)
        try KeychainClient.save("value-b", username: "account-b", serviceName: serviceName)

        #expect(try KeychainClient.get(username: "account-a", serviceName: serviceName) == "value-a")
        #expect(try KeychainClient.get(username: "account-b", serviceName: serviceName) == "value-b")
    }

    @Test("Given the same username, when save for different services, then values are isolated")
    func valuesIsolatedByService() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeychainClient.purge(serviceName: otherService) }

        try KeychainClient.save("value-1", username: username, serviceName: serviceName)
        try KeychainClient.save("value-2", username: username, serviceName: otherService)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == "value-1")
        #expect(try KeychainClient.get(username: username, serviceName: otherService) == "value-2")
    }

    // MARK: - delete

    @Test("Given a saved value, when delete, then get returns nil")
    func deleteRemovesValue() throws {
        try KeychainClient.save("user-123", username: username, serviceName: serviceName)

        try KeychainClient.delete(username: username, serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == nil)
    }

    @Test("Given no saved value, when delete, then it succeeds")
    func deleteMissingValueSucceeds() throws {
        #expect(try KeychainClient.delete(username: username, serviceName: serviceName))
    }

    @Test("Given multiple usernames in the same service, when delete one, then the others remain")
    func deleteOneKeepsOthers() throws {
        try KeychainClient.save("value-a", username: "account-a", serviceName: serviceName)
        try KeychainClient.save("value-b", username: "account-b", serviceName: serviceName)

        try KeychainClient.delete(username: "account-a", serviceName: serviceName)

        #expect(try KeychainClient.get(username: "account-a", serviceName: serviceName) == nil)
        #expect(try KeychainClient.get(username: "account-b", serviceName: serviceName) == "value-b")
    }

    // MARK: - purge

    @Test("Given multiple items in a service, when purge, then all are removed")
    func purgeRemovesAll() throws {
        try KeychainClient.save("value-a", username: "account-a", serviceName: serviceName)
        try KeychainClient.save("value-b", username: "account-b", serviceName: serviceName)

        try KeychainClient.purge(serviceName: serviceName)

        #expect(try KeychainClient.get(username: "account-a", serviceName: serviceName) == nil)
        #expect(try KeychainClient.get(username: "account-b", serviceName: serviceName) == nil)
    }

    @Test("Given no saved items, when purge, then it succeeds")
    func purgeEmptyServiceSucceeds() throws {
        #expect(try KeychainClient.purge(serviceName: serviceName))
    }

    @Test("Given items in another service, when purge, then the other service is unaffected")
    func purgeDoesNotAffectOtherService() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeychainClient.purge(serviceName: otherService) }
        try KeychainClient.save("keep-me", username: username, serviceName: otherService)
        try KeychainClient.save("purge-me", username: username, serviceName: serviceName)

        try KeychainClient.purge(serviceName: serviceName)

        #expect(try KeychainClient.get(username: username, serviceName: serviceName) == nil)
        #expect(try KeychainClient.get(username: username, serviceName: otherService) == "keep-me")
    }
}
