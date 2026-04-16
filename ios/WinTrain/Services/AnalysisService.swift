import Foundation

@MainActor
final class AnalysisService {
    private let apiClient: APIClient
    private let installIDStore: InstallIDStore
    private let quotaStore: QuotaStore

    init(apiClient: APIClient, installIDStore: InstallIDStore, quotaStore: QuotaStore) {
        self.apiClient = apiClient
        self.installIDStore = installIDStore
        self.quotaStore = quotaStore
    }

    func refreshQuota() async throws {
        let snapshot = try await apiClient.fetchQuota(installID: installIDStore.currentInstallID())
        quotaStore.update(snapshot)
    }

    func analyze(videoURL: URL, exerciseID: String) async throws -> AnalysisResult {
        let result = try await apiClient.uploadAnalysis(
            installID: installIDStore.currentInstallID(),
            exerciseID: exerciseID,
            videoURL: videoURL
        )
        quotaStore.update(result.quota)
        return result
    }
}
