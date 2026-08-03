import Foundation
import Security

enum KeychainError: Error {
    case unexpectedData
    case osStatus(OSStatus)
}

/// `SecItem` を薄く包む低レベルの Keychain アクセス（generic password）。
/// 上位の注入サービスは `KeychainUserIDStorage`（`UserIDStorage`）が担う。
enum KeychainClient {

    /// class/account/service の共通クエリ（各操作の土台）。
    private static func baseQuery(username: String, serviceName: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName
        ]
    }

    static func get(username: String, serviceName: String) throws -> String? {
        var query = baseQuery(username: username, serviceName: serviceName)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let value = String(data: data, encoding: .utf8) else {
                throw KeychainError.unexpectedData
            }
            return value
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.osStatus(status)
        }
    }

    @discardableResult
    static func save(_ value: String, username: String, serviceName: String, updateExisting: Bool = true) throws -> Bool {
        let valueData = Data(value.utf8) // String→UTF8 は常に成功する

        let existing = try get(username: username, serviceName: serviceName) // 本物のエラーはそのまま伝播させる
        if let existing {
            guard existing != value else { return true } // 既に同じ値
            guard updateExisting else { return false }
            return try update(valueData: valueData, username: username, serviceName: serviceName)
        }

        var newItem = baseQuery(username: username, serviceName: serviceName)
        newItem[kSecAttrLabel as String] = serviceName
        newItem[kSecValueData as String] = valueData
        // 端末に紐づく認証情報のため、バックアップ/他端末移行に含めない（初回アンロック以降アクセス可）。
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(newItem as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // get→add の間に他スレッドが先に作成した競合(TOCTOU)。updateExisting の意図を尊重する。
            guard updateExisting else { return false }
            return try update(valueData: valueData, username: username, serviceName: serviceName)
        }

        guard status == errSecSuccess else { throw KeychainError.osStatus(status) }
        return true
    }

    private static func update(valueData: Data, username: String, serviceName: String) throws -> Bool {
        let query = baseQuery(username: username, serviceName: serviceName)
        let attributes: [String: Any] = [kSecValueData as String: valueData]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeychainError.osStatus(status) }
        return true
    }

    @discardableResult
    static func delete(username: String, serviceName: String) throws -> Bool {
        let status = SecItemDelete(baseQuery(username: username, serviceName: serviceName) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.osStatus(status)
        }
        return true
    }

    @discardableResult
    static func purge(serviceName: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.osStatus(status)
        }
        return true
    }
}
