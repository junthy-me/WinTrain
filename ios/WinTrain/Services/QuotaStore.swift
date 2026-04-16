import Foundation

@MainActor
final class QuotaStore: ObservableObject {
    @Published private(set) var snapshot: QuotaSnapshot?

    private let defaults = UserDefaults.standard
    private let key = "wintrain.quota.snapshot"

    init() {
        if let data = defaults.data(forKey: key),
           let snapshot = try? JSONDecoder().decode(QuotaSnapshot.self, from: data) {
            self.snapshot = snapshot
        }
    }

    func update(_ snapshot: QuotaSnapshot) {
        self.snapshot = snapshot
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: key)
        }
    }
}
