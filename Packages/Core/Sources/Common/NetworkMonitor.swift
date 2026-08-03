import Foundation
import SystemConfiguration

/// 端末が通信可能か（到達性）を判定する抽象。通信の前チェックに使う。
/// テストではスタブに差し替える。
public protocol NetworkMonitoring: Sendable {
    /// 現在ネットワークに到達可能か。
    var isReachable: Bool { get }
}

/// `SCNetworkReachability` で、その時点の到達性を**同期的**に判定する実装。
///
/// 注意: Apple の `Network` framework（`NWPathMonitor`）は、当プロジェクトの
/// 同名モジュール `Network` と衝突して `import` できない（循環依存になる）ため、
/// 名前が衝突しない `SystemConfiguration` を用いる。同期判定なので監視スレッドや
/// 起動時ウォームアップは不要。
public struct SystemConfigurationNetworkMonitor: NetworkMonitoring {
    public init() {}

    public var isReachable: Bool {
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)

        guard let reachability = withUnsafePointer(to: &zeroAddress, { pointer in
            pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(reachability, &flags) else {
            return false
        }
        // 到達可能 かつ 追加接続が不要（自動でつながる）なら通信可能とみなす。
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
}
