import XCTest
@testable import LocalStorage

final class KeyChainUtilTests: XCTestCase {

    /// テストごとに固有のサービス名を使い、他テストや実アプリの Keychain 項目と干渉させない。
    private var serviceName = ""
    private let username = "test-account"

    override func setUp() {
        super.setUp()
        serviceName = "iOS-POC-2.KeyChainUtilTests.\(UUID().uuidString)"
    }

    override func tearDown() {
        try? KeyChainUtil.purge(serviceName: serviceName)
        super.tearDown()
    }

    // MARK: - get

    func test_givenNoSavedValue_whenGet_thenReturnsNil() throws {
        XCTAssertNil(try KeyChainUtil.get(username: username, serviceName: serviceName))
    }

    // MARK: - save

    func test_givenNoSavedValue_whenSave_thenGetReturnsSavedValue() throws {
        try KeyChainUtil.save("user-123", username: username, serviceName: serviceName)

        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "user-123")
    }

    func test_givenExistingValue_whenSaveDifferentValue_thenValueIsOverwritten() throws {
        try KeyChainUtil.save("old-value", username: username, serviceName: serviceName)

        try KeyChainUtil.save("new-value", username: username, serviceName: serviceName)

        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "new-value")
    }

    func test_givenExistingValue_whenSaveSameValue_thenReturnsTrueAndValueIsUnchanged() throws {
        try KeyChainUtil.save("same-value", username: username, serviceName: serviceName)

        let result = try KeyChainUtil.save("same-value", username: username, serviceName: serviceName)

        XCTAssertTrue(result)
        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "same-value")
    }

    func test_givenExistingValue_whenSaveWithUpdateExistingFalse_thenReturnsFalseAndValueIsUnchanged() throws {
        try KeyChainUtil.save("old-value", username: username, serviceName: serviceName)

        let result = try KeyChainUtil.save(
            "new-value",
            username: username,
            serviceName: serviceName,
            updateExisting: false
        )

        XCTAssertFalse(result)
        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "old-value")
    }

    func test_givenEmptyString_whenSave_thenGetReturnsEmptyString() throws {
        try KeyChainUtil.save("", username: username, serviceName: serviceName)

        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "")
    }

    func test_givenMultibyteString_whenSave_thenGetReturnsSameString() throws {
        try KeyChainUtil.save("ユーザー🔑", username: username, serviceName: serviceName)

        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "ユーザー🔑")
    }

    // MARK: - Isolation

    func test_givenSameService_whenSaveForDifferentUsernames_thenValuesAreIsolated() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        XCTAssertEqual(try KeyChainUtil.get(username: "account-a", serviceName: serviceName), "value-a")
        XCTAssertEqual(try KeyChainUtil.get(username: "account-b", serviceName: serviceName), "value-b")
    }

    func test_givenSameUsername_whenSaveForDifferentServices_thenValuesAreIsolated() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeyChainUtil.purge(serviceName: otherService) }

        try KeyChainUtil.save("value-1", username: username, serviceName: serviceName)
        try KeyChainUtil.save("value-2", username: username, serviceName: otherService)

        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: serviceName), "value-1")
        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: otherService), "value-2")
    }

    // MARK: - delete

    func test_givenSavedValue_whenDelete_thenGetReturnsNil() throws {
        try KeyChainUtil.save("user-123", username: username, serviceName: serviceName)

        try KeyChainUtil.delete(username: username, serviceName: serviceName)

        XCTAssertNil(try KeyChainUtil.get(username: username, serviceName: serviceName))
    }

    func test_givenNoSavedValue_whenDelete_thenSucceeds() throws {
        XCTAssertTrue(try KeyChainUtil.delete(username: username, serviceName: serviceName))
    }

    func test_givenMultipleUsernamesInSameService_whenDeleteOne_thenOthersRemain() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        try KeyChainUtil.delete(username: "account-a", serviceName: serviceName)

        XCTAssertNil(try KeyChainUtil.get(username: "account-a", serviceName: serviceName))
        XCTAssertEqual(try KeyChainUtil.get(username: "account-b", serviceName: serviceName), "value-b")
    }

    // MARK: - purge

    func test_givenMultipleItemsInService_whenPurge_thenAllAreRemoved() throws {
        try KeyChainUtil.save("value-a", username: "account-a", serviceName: serviceName)
        try KeyChainUtil.save("value-b", username: "account-b", serviceName: serviceName)

        try KeyChainUtil.purge(serviceName: serviceName)

        XCTAssertNil(try KeyChainUtil.get(username: "account-a", serviceName: serviceName))
        XCTAssertNil(try KeyChainUtil.get(username: "account-b", serviceName: serviceName))
    }

    func test_givenNoSavedItems_whenPurge_thenSucceeds() throws {
        XCTAssertTrue(try KeyChainUtil.purge(serviceName: serviceName))
    }

    func test_givenItemsInAnotherService_whenPurge_thenOtherServiceIsUnaffected() throws {
        let otherService = "\(serviceName).other"
        defer { try? KeyChainUtil.purge(serviceName: otherService) }
        try KeyChainUtil.save("keep-me", username: username, serviceName: otherService)
        try KeyChainUtil.save("purge-me", username: username, serviceName: serviceName)

        try KeyChainUtil.purge(serviceName: serviceName)

        XCTAssertNil(try KeyChainUtil.get(username: username, serviceName: serviceName))
        XCTAssertEqual(try KeyChainUtil.get(username: username, serviceName: otherService), "keep-me")
    }
}
