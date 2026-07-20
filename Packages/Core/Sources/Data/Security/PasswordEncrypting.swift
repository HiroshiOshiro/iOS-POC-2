import Foundation
import CryptoKit

/// パスワードを通信前に暗号化（ハッシュ化）するための seam となる interface。
///
/// これは純 Swift の抽象で、実装が ObjC か Swift かを利用側に意識させない。
/// アプリ本体では ObjC 実装（`PasswordCryptoUtil`）を包む adapter に差し替える。
public protocol PasswordEncrypting: Sendable {
    /// パスワードを暗号化した文字列を返す。
    func encrypt(_ password: String) throws -> String
}

/// Core が提供するデフォルト実装（純 Swift）。
/// アプリ本体で ObjC 実装に差し替えられる想定だが、パッケージ単体でも動くように用意する。
public struct CryptoKitPasswordEncryptor: PasswordEncrypting {
    public init() {}

    public func encrypt(_ password: String) throws -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
