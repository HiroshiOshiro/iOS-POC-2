import Foundation

/// 永続化キーの定義。
///
/// メールアドレスは LocalStorage 層が UserDefaults へ書き込み、UI 側は SwiftUI の
/// `@AppStorage` で同じキーを購読する。LocalStorage はキーを注入で受け取るため、
/// 実体はここ（Data）で一元管理する。
public enum StorageKeys {
    public static let loginEmail = "login_email"
}
