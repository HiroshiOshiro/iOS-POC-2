import Data

/// ObjC の `PasswordCryptoUtil` を Swift の `PasswordEncrypting` に適合させる adapter。
///
/// ObjC（Bridging Header 経由の `PasswordCryptoUtil`）を直接参照するのはこのファイルだけ。
/// Core/Feature のパッケージ側は `PasswordEncrypting` protocol 越しに使うため、ObjC を一切知らない。
struct ObjCPasswordEncryptor: PasswordEncrypting {
    func encrypt(_ password: String) throws -> String {
        guard let hashed = PasswordCryptoUtil.sha256Hex(of: password) else {
            throw ObjCPasswordEncryptorError.encryptionFailed
        }
        return hashed
    }
}

enum ObjCPasswordEncryptorError: Error {
    case encryptionFailed
}
