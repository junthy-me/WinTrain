import Foundation

@MainActor
final class SubscriptionService {
    private let apiClient: APIClient
    private let installIDStore: InstallIDStore
    private let quotaStore: QuotaStore

    init(apiClient: APIClient, installIDStore: InstallIDStore, quotaStore: QuotaStore) {
        self.apiClient = apiClient
        self.installIDStore = installIDStore
        self.quotaStore = quotaStore
    }

    func activate(productID: String, originalTransactionID: String, signedTransactionInfo: String) async throws -> SubscriptionResult {
        let result = try await apiClient.activateSubscription(
            installID: installIDStore.currentInstallID(),
            productID: productID,
            originalTransactionID: originalTransactionID,
            signedTransactionInfo: signedTransactionInfo
        )
        quotaStore.update(result.quota)
        return result
    }

    func restore(originalTransactionID: String) async throws -> SubscriptionResult {
        let result = try await apiClient.restoreSubscription(
            installID: installIDStore.currentInstallID(),
            originalTransactionID: originalTransactionID
        )
        quotaStore.update(result.quota)
        return result
    }
}
