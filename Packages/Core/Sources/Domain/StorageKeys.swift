import Foundation

/// 永続化キーの共有定義。
///
/// メールアドレスは LocalStorage 層が UserDefaults へ書き込み、UI 側は SwiftUI の
/// `@AppStorage` で同じキーを購読する。双方が同じキーを参照できるよう Domain に置く。
public enum StorageKeys {
    public static let loginEmail = "login_email"
}
