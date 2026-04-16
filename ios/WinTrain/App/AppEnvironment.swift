import Foundation
import WinTrainStoreKitSupport

@MainActor
final class AppEnvironment: ObservableObject {
    private enum Config {
        static let analysisEstimateKey = "analysis_estimated_duration_seconds"
        static let defaultAnalysisEstimateSeconds = 30.0
    }

    let apiClient: APIClient
    let installIDStore: InstallIDStore
    let quotaStore: QuotaStore
    let historyStore: HistoryStore
    let analysisService: AnalysisService
    let subscriptionService: SubscriptionService
    let storeKitCoordinator: StoreKitCoordinator
    let analysisEstimatedDurationSeconds: Double

    init() {
        let baseURL = URL(string: "http://localhost:8080")!
        let apiClient = APIClient(baseURL: baseURL)
        let installIDStore = InstallIDStore()
        let quotaStore = QuotaStore()
        let historyStore = HistoryStore()

        self.apiClient = apiClient
        self.installIDStore = installIDStore
        self.quotaStore = quotaStore
        self.historyStore = historyStore
        self.analysisService = AnalysisService(
            apiClient: apiClient,
            installIDStore: installIDStore,
            quotaStore: quotaStore
        )
        self.subscriptionService = SubscriptionService(
            apiClient: apiClient,
            installIDStore: installIDStore,
            quotaStore: quotaStore
        )
        self.storeKitCoordinator = StoreKitCoordinator()
        self.analysisEstimatedDurationSeconds = Self.loadAnalysisEstimatedDurationSeconds()
    }

    private static func loadAnalysisEstimatedDurationSeconds() -> Double {
        let environment = ProcessInfo.processInfo.environment
        if let raw = environment["WINTRAIN_ANALYSIS_ESTIMATE_SECONDS"],
           let value = Double(raw),
           value > 0 {
            return value
        }

        let stored = UserDefaults.standard.double(forKey: Config.analysisEstimateKey)
        if stored > 0 {
            return stored
        }

        return Config.defaultAnalysisEstimateSeconds
    }
}
