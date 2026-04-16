import Foundation

struct Exercise: Identifiable, Hashable {
    let id: String
    let name: String
    let targets: String
    let cameraHint: String
    let imageAssetName: String
    let defaultWeight: String
    let defaultReps: String

    var view: String {
        cameraHint
    }
}

struct FeedbackItem: Codable, Hashable, Identifiable {
    var id: Int { rank }
    let rank: Int
    let title: String
    let description: String
    let howToFix: String
    let cue: String
    let severity: String
    let clip: ClipRange?

    enum CodingKeys: String, CodingKey {
        case rank
        case title
        case description
        case howToFix = "how_to_fix"
        case cue
        case severity
        case clip
    }
}

struct ClipRange: Codable, Hashable {
    let startMS: Int
    let endMS: Int

    enum CodingKeys: String, CodingKey {
        case startMS = "start_ms"
        case endMS = "end_ms"
    }
}

struct QuotaSnapshot: Codable, Hashable {
    let plan: String
    let remainingTotalSuccesses: Int?
    let dailyRemainingSuccesses: Int?
    let isPro: Bool
    let snapshotAt: String
    let expiresAt: String

    enum CodingKeys: String, CodingKey {
        case plan
        case remainingTotalSuccesses = "remaining_total_successes"
        case dailyRemainingSuccesses = "daily_remaining_successes"
        case isPro = "is_pro"
        case snapshotAt = "snapshot_at"
        case expiresAt = "expires_at"
    }
}

struct AnalysisResult: Codable, Hashable {
    let sessionID: String
    let videoSource: String
    let status: String
    let exerciseID: String
    let overallSummary: String
    let memoryCue: String?
    let feedbacks: [FeedbackItem]
    let lowConfidenceReason: String?
    let quota: QuotaSnapshot

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case videoSource = "video_source"
        case status
        case exerciseID = "exercise_id"
        case overallSummary = "overall_summary"
        case memoryCue = "memory_cue"
        case feedbacks
        case lowConfidenceReason = "low_confidence_reason"
        case quota
    }
}

struct SubscriptionPayload: Codable, Hashable {
    let status: String
    let productID: String
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case status
        case productID = "product_id"
        case expiresAt = "expires_at"
    }
}

struct SubscriptionResult: Codable, Hashable {
    let subscription: SubscriptionPayload
    let quota: QuotaSnapshot
}

struct HistoryRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let sessionID: String
    let exerciseID: String
    let exerciseName: String
    let createdAt: Date
    let overallSummary: String
    let memoryCue: String?
    let primaryFeedbackTitle: String
    let localClipPath: String?
    let result: AnalysisResult
}

enum AppError: Error, LocalizedError {
    case invalidResponse
    case invalidVideo
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "服务返回了无法识别的数据。"
        case .invalidVideo:
            return "请先选择一个有效的视频文件。"
        case .server(let message):
            return message
        }
    }
}

extension Exercise {
    static let supported: [Exercise] = [
        Exercise(
            id: "squat",
            name: "杠铃深蹲",
            targets: "股四头肌、臀大肌",
            cameraHint: "侧前方 30°～45°",
            imageAssetName: "SquatGuide",
            defaultWeight: "100kg",
            defaultReps: "12×4"
        ),
        Exercise(
            id: "lat-pulldown",
            name: "坐姿高位下拉",
            targets: "背阔肌、大圆肌",
            cameraHint: "侧后方 30°～45°",
            imageAssetName: "LatPulldownGuide",
            defaultWeight: "50kg",
            defaultReps: "10×4"
        ),
    ]

    static func find(_ id: String) -> Exercise {
        supported.first(where: { $0.id == id }) ?? supported[0]
    }
}

extension HistoryRecord {
    static let demoRecentRecord = makeDemoRecentRecord()
    static let demoListRecords = makeDemoListRecords()

    private static func makeDemoRecentRecord() -> HistoryRecord {
        HistoryRecord(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            sessionID: "demo-home-recent",
            exerciseID: "squat",
            exerciseName: "杠铃深蹲",
            createdAt: demoDate(year: 2023, month: 10, day: 24, hour: 18, minute: 30),
            overallSummary: "重心不稳：杠铃上下时没有尽量走直线",
            memoryCue: "让杠铃走直线，脚底踩稳。",
            primaryFeedbackTitle: "重心不稳",
            localClipPath: nil,
            result: AnalysisResult.demoNeedImproveSquat
        )
    }

    private static func makeDemoListRecords() -> [HistoryRecord] {
        [
            HistoryRecord(
                id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
                sessionID: "demo-history-1",
                exerciseID: "squat",
                exerciseName: "杠铃深蹲",
                createdAt: demoDate(year: 2023, month: 10, day: 25, hour: 10, minute: 30),
                overallSummary: "动作标准，控制稳定，继续保持",
                memoryCue: "稳扎稳打，继续保持！",
                primaryFeedbackTitle: "动作优秀",
                localClipPath: nil,
                result: AnalysisResult.demoExcellentSquat
            ),
            HistoryRecord(
                id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
                sessionID: "demo-history-2",
                exerciseID: "lat-pulldown",
                exerciseName: "坐姿高位下拉",
                createdAt: demoDate(year: 2023, month: 10, day: 24, hour: 15, minute: 45),
                overallSummary: "背部未先发力：更像是在用手把杆拉下来",
                memoryCue: "先沉肩，后下拉。",
                primaryFeedbackTitle: "背部未先发力",
                localClipPath: nil,
                result: AnalysisResult.demoNeedImproveLatPulldown
            ),
            HistoryRecord(
                id: UUID(uuidString: "44444444-4444-4444-4444-444444444444") ?? UUID(),
                sessionID: "demo-history-3",
                exerciseID: "squat",
                exerciseName: "杠铃深蹲",
                createdAt: demoDate(year: 2023, month: 10, day: 20, hour: 9, minute: 15),
                overallSummary: "膝盖内收：下蹲或起身时膝盖有往里跑的趋势",
                memoryCue: "膝盖跟着脚趾方向走，髋关节做外旋对抗。",
                primaryFeedbackTitle: "膝盖内收",
                localClipPath: nil,
                result: AnalysisResult.demoNeedImproveKnee
            ),
        ]
    }

    private static func demoDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return components.date ?? .now
    }
}

extension AnalysisResult {
    static let demoNeedImproveSquat = makeDemoNeedImproveSquat()
    static let demoExcellentSquat = makeDemoExcellentSquat()
    static let demoNeedImproveLatPulldown = makeDemoNeedImproveLatPulldown()
    static let demoNeedImproveKnee = makeDemoNeedImproveKnee()

    private static func makeDemoNeedImproveSquat() -> AnalysisResult {
        AnalysisResult(
            sessionID: "demo-home-recent",
            videoSource: "local_demo",
            status: "success",
            exerciseID: "squat",
            overallSummary: "重心不稳：杠铃上下时没有尽量走直线",
            memoryCue: "让杠铃走直线，脚底踩稳。",
            feedbacks: [
                FeedbackItem(
                    rank: 1,
                    title: "重心不稳",
                    description: "杠铃上下时没有尽量走直线，力量传递不稳。",
                    howToFix: "下蹲和起身过程中脚趾主动抓地，保持脚底压力稳定，让杠铃尽量垂直上下。",
                    cue: "让杠铃走直线，脚底踩稳。",
                    severity: "warning",
                    clip: nil
                )
            ],
            lowConfidenceReason: nil,
            quota: demoQuota
        )
    }

    private static func makeDemoExcellentSquat() -> AnalysisResult {
        AnalysisResult(
            sessionID: "demo-history-1",
            videoSource: "local_demo",
            status: "success",
            exerciseID: "squat",
            overallSummary: "动作标准，控制稳定，继续保持",
            memoryCue: "稳扎稳打，继续保持！",
            feedbacks: [
                FeedbackItem(
                    rank: 1,
                    title: "动作优秀",
                    description: "动作标准，控制稳定，继续保持。",
                    howToFix: "继续保持当前的动作标准，可以尝试逐渐增加重量或次数。",
                    cue: "稳扎稳打，继续保持！",
                    severity: "info",
                    clip: nil
                )
            ],
            lowConfidenceReason: nil,
            quota: demoQuota
        )
    }

    private static func makeDemoNeedImproveLatPulldown() -> AnalysisResult {
        AnalysisResult(
            sessionID: "demo-history-2",
            videoSource: "local_demo",
            status: "success",
            exerciseID: "lat-pulldown",
            overallSummary: "背部未先发力：更像是在用手把杆拉下来",
            memoryCue: "先沉肩，后下拉。",
            feedbacks: [
                FeedbackItem(
                    rank: 1,
                    title: "背部未先发力",
                    description: "更像是在用手把杆拉下来，而不是先让肩沉下去。",
                    howToFix: "先想肩往下沉，再想肘往下压。",
                    cue: "先沉肩，后下拉。",
                    severity: "warning",
                    clip: nil
                )
            ],
            lowConfidenceReason: nil,
            quota: demoQuota
        )
    }

    private static func makeDemoNeedImproveKnee() -> AnalysisResult {
        AnalysisResult(
            sessionID: "demo-history-3",
            videoSource: "local_demo",
            status: "success",
            exerciseID: "squat",
            overallSummary: "膝盖内收：下蹲或起身时膝盖有往里跑的趋势",
            memoryCue: "膝盖跟着脚趾方向走，髋关节做外旋对抗。",
            feedbacks: [
                FeedbackItem(
                    rank: 1,
                    title: "膝盖内收",
                    description: "下蹲或起身时膝盖有往里跑的趋势，说明稳定性还不够。",
                    howToFix: "下蹲和站起时保证膝盖朝第二个脚趾方向移动，同时髋关节做外旋对抗。",
                    cue: "膝盖跟着脚趾方向走，髋关节做外旋对抗。",
                    severity: "warning",
                    clip: nil
                )
            ],
            lowConfidenceReason: nil,
            quota: demoQuota
        )
    }

    private static let demoQuota = QuotaSnapshot(
        plan: "free",
        remainingTotalSuccesses: 3,
        dailyRemainingSuccesses: 1,
        isPro: false,
        snapshotAt: "2026-04-07T09:00:00Z",
        expiresAt: "2026-04-08T09:00:00Z"
    )
}
