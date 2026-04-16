import Foundation

enum AppTab: String, CaseIterable, Hashable {
    case home
    case capture
    case history
    case profile

    var title: String {
        switch self {
        case .home:
            return "首页"
        case .capture:
            return "拍摄"
        case .history:
            return "记录"
        case .profile:
            return "我的"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .capture:
            return "video"
        case .history:
            return "clock.arrow.circlepath"
        case .profile:
            return "person"
        }
    }
}

struct ResultScreenContext: Hashable {
    enum Source: Hashable {
        case analysis
        case history
    }

    let exerciseID: String
    let result: AnalysisResult?
    let failureReason: String?
    let localClipPath: String?
    let recordID: UUID?
    let source: Source

    static func analysis(result: AnalysisResult, exerciseID: String, localClipPath: String?) -> Self {
        Self(exerciseID: exerciseID, result: result, failureReason: nil, localClipPath: localClipPath, recordID: nil, source: .analysis)
    }

    static func history(_ record: HistoryRecord) -> Self {
        Self(exerciseID: record.exerciseID, result: record.result, failureReason: nil, localClipPath: record.localClipPath, recordID: record.id, source: .history)
    }

    static func failure(exerciseID: String, reason: String?) -> Self {
        Self(exerciseID: exerciseID, result: nil, failureReason: reason, localClipPath: nil, recordID: nil, source: .analysis)
    }
}

enum AppRoute: Hashable {
    case guide(exerciseID: String)
    case analyzing(exerciseID: String)
    case result(ResultScreenContext)
    case paywall
    case helpFeedback
    case privacyNotice
}

@MainActor
final class AppRouter: ObservableObject {
    @Published private(set) var selectedTab: AppTab = .home
    @Published private(set) var stack: [AppRoute] = []

    var currentRoute: AppRoute? {
        stack.last
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
        stack.removeAll()
    }

    func push(_ route: AppRoute) {
        stack.append(route)
    }

    func replaceTop(with route: AppRoute) {
        if stack.isEmpty {
            stack = [route]
        } else {
            stack.removeLast()
            stack.append(route)
        }
    }

    func pop() {
        guard !stack.isEmpty else { return }
        stack.removeLast()
    }

    func popToRoot() {
        stack.removeAll()
    }
}
