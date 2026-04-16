import Foundation

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var records: [HistoryRecord] = []

    private let fileURL: URL
    private let fileManager = FileManager.default

    init() {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = directory.appending(path: "history.json")
        load()
    }

    func append(result: AnalysisResult, exerciseName: String, localClipPath: String?) {
        guard result.status == "success" else { return }
        let record = HistoryRecord(
            id: UUID(),
            sessionID: result.sessionID,
            exerciseID: result.exerciseID,
            exerciseName: exerciseName,
            createdAt: .now,
            overallSummary: result.overallSummary,
            memoryCue: result.memoryCue,
            primaryFeedbackTitle: result.feedbacks.first?.title ?? result.overallSummary,
            localClipPath: localClipPath,
            result: result
        )
        records.insert(record, at: 0)
        save()
    }

    func delete(recordID: UUID) {
        guard let index = records.firstIndex(where: { $0.id == recordID }) else { return }
        let record = records.remove(at: index)
        deleteClipIfNeeded(at: record.localClipPath)
        save()
    }

    private func deleteClipIfNeeded(at path: String?) {
        guard let path, path.isEmpty == false else { return }
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? fileManager.removeItem(at: base.appending(path: path))
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let records = try? JSONDecoder().decode([HistoryRecord].self, from: data) else {
            return
        }
        self.records = records
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
