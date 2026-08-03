import FactoryKit
import Common

/// 到達性判定の登録（`SCNetworkReachability` ベースの同期判定）。
/// テストでは `Container.shared.networkMonitor.register { StubNetworkMonitor(...) }` で差し替える。
public extension Container {
    var networkMonitor: Factory<any NetworkMonitoring> {
        self { SystemConfigurationNetworkMonitor() }
    }
}
