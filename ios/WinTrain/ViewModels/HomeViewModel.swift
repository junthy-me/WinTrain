import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var exercises: [Exercise] = Exercise.supported

    private var analysisService: AnalysisService

    init(analysisService: AnalysisService) {
        self.analysisService = analysisService
    }

    func replaceAnalysisService(_ analysisService: AnalysisService) {
        self.analysisService = analysisService
    }

    func usesSame(analysisService: AnalysisService) -> Bool {
        self.analysisService === analysisService
    }

    func refreshQuota() async {
        try? await analysisService.refreshQuota()
    }
}
