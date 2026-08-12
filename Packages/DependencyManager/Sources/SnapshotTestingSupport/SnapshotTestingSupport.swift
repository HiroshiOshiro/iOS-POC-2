/// `import SnapshotTestingSupport` だけで pointfreeco/swift-snapshot-testing の API
/// （`assertSnapshot` 等）がそのまま使えるようにする再エクスポート。
///
/// 外部 URL への参照は `Package.swift` にのみ存在し、この行から先（ソースコード側）には
/// 一切現れない。
@_exported import SnapshotTesting
