import Foundation
import Security

enum KeyChainError: Error {
    case invalidInput
    case unexpectedData
    case osStatus(OSStatus)
}

enum KeyChainUtil {

    static func get(username: String, serviceName: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let password = String(data: data, encoding: .utf8) else {
                throw KeyChainError.unexpectedData
            }
            return password
        case errSecItemNotFound:
            return nil
        default:
            throw KeyChainError.osStatus(status)
        }
    }

    @discardableResult
    static func save(_ value: String, username: String, serviceName: String, updateExisting: Bool = true) throws -> Bool {
        guard let valueData = value.data(using: .utf8) else {
            throw KeyChainError.invalidInput
        }

        let existing = try get(username: username, serviceName: serviceName) // 本物のエラーはそのまま伝播させる

        if let existing {
            guard existing != value else { return true } // 既に同じ値
            guard updateExisting else { return false }
            return try update(valueData: valueData, username: username, serviceName: serviceName)
        }

        let newItem: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName,
            kSecAttrLabel as String: serviceName,
            kSecValueData as String: valueData
        ]
        let status = SecItemAdd(newItem as CFDictionary, nil)

        if status == errSecDuplicateItem {
            // get直後にaddの間で他スレッドが先に作成した場合の競合状態(TOCTOU)対策
            return try update(valueData: valueData, username: username, serviceName: serviceName)
        }

        guard status == errSecSuccess else { throw KeyChainError.osStatus(status) }
        return true
    }

    private static func update(valueData: Data, username: String, serviceName: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName
        ]
        let attributes: [String: Any] = [kSecValueData as String: valueData]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status == errSecSuccess else { throw KeyChainError.osStatus(status) }
        return true
    }

    @discardableResult
    static func delete(username: String, serviceName: String) throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecAttrService as String: serviceName
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeyChainError.osStatus(status)
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
            throw KeyChainError.osStatus(status)
        }
        return true
    }
}
