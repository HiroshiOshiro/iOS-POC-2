import FactoryKit

/// Data 層が提供するセキュリティ関連の依存の登録。
/// NiA 相当: core:data の di（Hilt モジュール）。
public extension Container {

    /// パスワード暗号化の実装。
    /// デフォルトは純 Swift の `CryptoKitPasswordEncryptor`。
    /// アプリ本体（合成ルート）で ObjC 実装の adapter に差し替える。
    var passwordEncryptor: Factory<any PasswordEncrypting> {
        self { CryptoKitPasswordEncryptor() }
    }
}
