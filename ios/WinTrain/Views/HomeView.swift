import SwiftUI

struct HomeView: View {
    private enum Layout {
        static let screenHorizontalPadding: CGFloat = 24
        static let screenTopPadding: CGFloat = 32
        static let screenBottomPadding: CGFloat = 24
        static let sectionSpacing: CGFloat = 32
        static let subsectionSpacing: CGFloat = 16
        static let cardCornerRadius: CGFloat = 32
        static let exerciseCardHeight: CGFloat = 128
        static let exerciseCardSpacing: CGFloat = 16
    }

    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var quotaStore: QuotaStore
    @EnvironmentObject private var historyStore: HistoryStore
    @StateObject var viewModel: HomeViewModel
    @StateObject var flowViewModel: AnalysisFlowViewModel

    private var recentRecord: HistoryRecord? {
        historyStore.records.max(by: { $0.createdAt < $1.createdAt })
    }

    private var quickExercises: [Exercise] {
        viewModel.exercises
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(proxy.size.width - (Layout.screenHorizontalPadding * 2), 0)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Layout.sectionSpacing) {
                    header
                    quotaCard
                    primaryAction
                    quickSelectSection
                    if let recentRecord {
                        recentSection(record: recentRecord)
                    }
                }
                .frame(width: contentWidth, alignment: .topLeading)
                .padding(.horizontal, Layout.screenHorizontalPadding)
                .padding(.top, Layout.screenTopPadding)
                .padding(.bottom, Layout.screenBottomPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppSurfaceBackground())
            .task {
                await viewModel.refreshQuota()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppBrandLockup(titleSize: 34, subtitleSize: 11, subtitlePill: true)

            Text("今天想分析哪个动作？")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private var quotaCard: some View {
        AppCard(padding: 24, cornerRadius: Layout.cardCornerRadius) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日状态")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .tracking(1.8)
                        .textCase(.uppercase)

                    quotaHeadline

                    Text("成功生成结果后才计次，失败不计次")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.9))
                        .padding(.top, 8)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.primary.opacity(0.12))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(AppTheme.primary)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.5), radius: 24, y: 10)
    }

    private var primaryAction: some View {
        Button {
            router.selectTab(.capture)
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "video.fill")
                    .font(.system(size: 24, weight: .semibold))
                Text("开始拍摄")
                    .font(.system(size: 20, weight: .bold))
                    .tracking(0.6)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .foregroundStyle(.white)
            .background(AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(0.2), radius: 16, y: 8)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }

    private var quickSelectSection: some View {
        VStack(alignment: .leading, spacing: Layout.subsectionSpacing) {
            AppSectionLabel(title: "选择动作")

            GeometryReader { proxy in
                let cardWidth = max((proxy.size.width - (Layout.exerciseCardSpacing * 1.5)) / 2.5, 120)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Layout.exerciseCardSpacing) {
                        ForEach(quickExercises) { exercise in
                            Button {
                                router.push(.guide(exerciseID: exercise.id))
                            } label: {
                                quickExerciseCard(exercise: exercise, cardWidth: cardWidth)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.trailing, cardWidth * 0.2)
                }
            }
            .frame(height: Layout.exerciseCardHeight)
        }
    }

    private func quickExerciseCard(exercise: Exercise, cardWidth: CGFloat) -> some View {
        let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)
        let gradient = LinearGradient(
            colors: [.clear, Color.black.opacity(0.15), Color.black.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )

        return Color.clear
            .frame(width: cardWidth, height: Layout.exerciseCardHeight)
            .overlay {
                AppRemoteImage(assetName: exercise.imageAssetName, contentMode: .fill)
            }
            .overlay {
                gradient
            }
            .overlay(alignment: .bottomLeading) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 12)
                    .shadow(color: Color.black.opacity(0.35), radius: 8, y: 4)
            }
            .background(AppTheme.card)
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
    }

    private func recentSection(record recentRecord: HistoryRecord) -> some View {
        VStack(alignment: .leading, spacing: Layout.subsectionSpacing) {
            HStack {
                AppSectionLabel(title: "最近一次分析")
                Spacer()
                Button {
                    router.selectTab(.history)
                } label: {
                    HStack(spacing: 2) {
                        Text("历史记录")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                }
                .buttonStyle(.plain)
            }

            Button {
                router.push(.result(.history(recentRecord)))
            } label: {
                AppCard(padding: 0, cornerRadius: 16) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recentRecord.exerciseName)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(homeRecentDateString(for: recentRecord.createdAt))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }

                            Spacer()

                            AppStatusChip(
                                title: resultStatusTitle(for: recentRecord.result),
                                style: resultStatusStyle(for: recentRecord.result)
                            )
                        }
                        .padding(16)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("主要问题摘要")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)

                            HStack(alignment: .center, spacing: 6) {
                                Image(systemName: recentSummaryIcon(for: recentRecord.result))
                                    .font(.system(size: 14, weight: .semibold))
                                Text(recentRecord.primaryFeedbackTitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(2)
                            }
                            .foregroundStyle(recentSummaryColor(for: recentRecord.result))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(AppTheme.background.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(AppTheme.border.opacity(0.5), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .padding(.horizontal, 16)

                        HStack {
                            Spacer()
                            HStack(spacing: 4) {
                                Text("查看详情")
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func homeRecentDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 · HH:mm"
        return formatter.string(from: date)
    }

    private func recentSummaryIcon(for result: AnalysisResult) -> String {
        switch resultStatusTitle(for: result) {
        case "优秀":
            return "checkmark.circle.fill"
        case "良好":
            return "checkmark.seal.fill"
        case "需改进":
            return "exclamationmark.triangle.fill"
        default:
            return "info.circle.fill"
        }
    }

    private func recentSummaryColor(for result: AnalysisResult) -> Color {
        switch resultStatusTitle(for: result) {
        case "优秀":
            return AppTheme.success
        case "良好":
            return AppTheme.primary
        case "需改进":
            return AppTheme.warning
        default:
            return AppTheme.textSecondary
        }
    }

    @ViewBuilder
    private var quotaHeadline: some View {
        if let snapshot = quotaStore.snapshot, snapshot.isPro {
            Text("专业版已激活")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text("无限分析")
                .font(.system(size: 30, weight: .black))
                .foregroundStyle(AppTheme.primary)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("今日剩余：")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(dailyQuotaText)
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(AppTheme.primary)
                }

                Text("累计剩余：\(totalQuotaText)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var dailyQuotaText: String {
        if let snapshot = quotaStore.snapshot {
            return String(snapshot.dailyRemainingSuccesses ?? 0)
        }
        return "1"
    }

    private var totalQuotaText: String {
        if let snapshot = quotaStore.snapshot {
            return String(snapshot.remainingTotalSuccesses ?? 0)
        }
        return "3"
    }
}
