import FactoryKit
import Data

/// アプリ本体（合成ルート）での依存の差し替え。
///
/// Factory の `AutoRegistering` により、最初の解決前に一度だけ自動で呼ばれる。
/// ここで Core の既定（純 Swift 実装）を ObjC 実装の adapter に差し替える。
/// NiA 相当: :app の DI（Hilt の `@HiltAndroidApp NiaApplication` とアプリ層のモジュール）。
extension Container: @retroactive AutoRegistering {
    public func autoRegister() {
        passwordEncryptor.register { ObjCPasswordEncryptor() }
    }
}
