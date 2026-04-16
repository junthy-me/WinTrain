import Foundation

@MainActor
final class AnalysisFlowViewModel: ObservableObject {
    @Published var selectedExercise: Exercise?
    @Published var selectedVideoURL: URL?
    @Published var isSubmitting = false
    @Published var latestResult: AnalysisResult?
    @Published var latestClipPath: String?
    @Published var errorMessage: String?
    @Published var uploadProgress = 0.0

    private var analysisService: AnalysisService
    private var historyStore: HistoryStore
    private var retryAttempted = false

    init(analysisService: AnalysisService, historyStore: HistoryStore) {
        self.analysisService = analysisService
        self.historyStore = historyStore
    }

    func replaceDependencies(analysisService: AnalysisService, historyStore: HistoryStore) {
        self.analysisService = analysisService
        self.historyStore = historyStore
    }

    func usesSame(analysisService: AnalysisService, historyStore: HistoryStore) -> Bool {
        self.analysisService === analysisService && self.historyStore === historyStore
    }

    func prepare(exercise: Exercise, videoURL: URL) {
        selectedExercise = exercise
        selectedVideoURL = videoURL
        resetResult()
    }

    func submit() async {
        guard let selectedExercise, let selectedVideoURL else {
            errorMessage = AppError.invalidVideo.localizedDescription
            return
        }

        isSubmitting = true
        uploadProgress = 0.2
        errorMessage = nil
        defer {
            isSubmitting = false
            uploadProgress = latestResult == nil ? 0 : 1
        }

        do {
            let importedVideoStore = ImportedVideoStore()
            let importedVideoURL = try importedVideoStore.importVideo(from: selectedVideoURL)
            defer {
                importedVideoStore.removeImportedVideo(at: importedVideoURL)
            }

            uploadProgress = 0.5
            let result = try await analyzeWithRetry(videoURL: importedVideoURL, exerciseID: selectedExercise.id)
            uploadProgress = 0.9
            latestResult = result
            latestClipPath = try? await exportPrimaryClipIfNeeded(from: importedVideoURL, result: result)
            historyStore.append(result: result, exerciseName: selectedExercise.name, localClipPath: latestClipPath)
            retryAttempted = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetResult() {
        latestResult = nil
        latestClipPath = nil
        errorMessage = nil
        uploadProgress = 0
    }

    func resetFlow() {
        selectedExercise = nil
        selectedVideoURL = nil
        isSubmitting = false
        retryAttempted = false
        resetResult()
    }

    private func analyzeWithRetry(videoURL: URL, exerciseID: String) async throws -> AnalysisResult {
        do {
            return try await analysisService.analyze(videoURL: videoURL, exerciseID: exerciseID)
        } catch {
            guard retryAttempted == false else { throw error }
            retryAttempted = true
            let result = try await analysisService.analyze(videoURL: videoURL, exerciseID: exerciseID)
            retryAttempted = false
            return result
        }
    }

    private func exportPrimaryClipIfNeeded(from videoURL: URL, result: AnalysisResult) async throws -> String? {
        guard result.status == "success",
              let primaryFeedback = result.feedbacks.first,
              hasPrimaryProblemCardContent(primaryFeedback),
              let clip = primaryFeedback.clip else {
            return nil
        }

        let clipURL = try await VideoClipService().exportPrimaryClip(
            from: videoURL,
            clip: clip,
            sessionID: result.sessionID
        )
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let basePath = base.path
        let fullPath = clipURL.path
        guard fullPath.hasPrefix(basePath) else { return clipURL.lastPathComponent }
        return String(fullPath.dropFirst(basePath.count)).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func hasPrimaryProblemCardContent(_ feedback: FeedbackItem) -> Bool {
        [
            feedback.title,
            feedback.description,
            feedback.howToFix,
            feedback.cue,
        ]
        .contains { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }
}
