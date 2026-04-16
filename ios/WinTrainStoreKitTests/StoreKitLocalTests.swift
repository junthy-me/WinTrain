import XCTest
import StoreKit
import StoreKitTest
@testable import WinTrainStoreKitSupport

@available(iOS 17.0, *)
final class StoreKitLocalTests: XCTestCase {
    private var session: SKTestSession!

    override func setUpWithError() throws {
        guard Bundle(for: Self.self).url(forResource: "WinTrainLocal", withExtension: "storekit") != nil else {
            throw NSError(
                domain: "StoreKitLocalTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "WinTrainLocal.storekit is missing from the test bundle."]
            )
        }

        session = try SKTestSession(configurationFileNamed: "WinTrainLocal")
    }

    override func tearDown() {
        session = nil
        super.tearDown()
    }

    func testPurchaseMonthlySubscription() async throws {
        let transaction = try await session.buyProduct(identifier: StoreKitCoordinator.monthlyProductID)
        let coordinator = await MainActor.run { StoreKitCoordinator() }
        await coordinator.refreshCurrentEntitlements()

        let isSubscribed = await MainActor.run { coordinator.isSubscribed }
        let originalID = await MainActor.run { coordinator.latestTransactionOriginalID }
        XCTAssertTrue(isSubscribed)
        XCTAssertEqual(originalID, transaction.originalID)
        XCTAssertEqual(session.allTransactions().count, 1)
    }

    func testRestorePurchaseKeepsEntitlement() async throws {
        _ = try await session.buyProduct(identifier: StoreKitCoordinator.monthlyProductID)
        let coordinator = await MainActor.run { StoreKitCoordinator() }
        await coordinator.restorePurchases()

        let isSubscribed = await MainActor.run { coordinator.isSubscribed }
        let originalID = await MainActor.run { coordinator.latestTransactionOriginalID }
        XCTAssertTrue(isSubscribed)
        XCTAssertNotNil(originalID)
    }

    func testSubscriptionRenewsInLocalSession() async throws {
        _ = try await session.buyProduct(identifier: StoreKitCoordinator.monthlyProductID)
        let coordinator = await MainActor.run { StoreKitCoordinator() }

        try session.forceRenewalOfSubscription(productIdentifier: StoreKitCoordinator.monthlyProductID)
        try await Task.sleep(for: .seconds(1))
        await coordinator.refreshCurrentEntitlements()

        XCTAssertGreaterThanOrEqual(session.allTransactions().count, 2)
        let isSubscribed = await MainActor.run { coordinator.isSubscribed }
        XCTAssertTrue(isSubscribed)
    }

    func testRefundRevokesEntitlement() async throws {
        _ = try await session.buyProduct(identifier: StoreKitCoordinator.monthlyProductID)
        let coordinator = await MainActor.run { StoreKitCoordinator() }

        let transactions = session.allTransactions()
        XCTAssertEqual(transactions.count, 1)
        guard let transaction = transactions.first else {
            throw XCTSkip("No transaction available to refund.")
        }

        try session.refundTransaction(identifier: transaction.identifier)
        try await Task.sleep(for: .seconds(1))
        await coordinator.refreshCurrentEntitlements()

        let isSubscribed = await MainActor.run { coordinator.isSubscribed }
        XCTAssertFalse(isSubscribed)
    }
}
