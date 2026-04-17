import AVFoundation
import AVKit
import SwiftUI
import UIKit

struct ResultView: View {
    private enum ResultDisplayState {
        case success
        case lowConfidence
        case failed
        case exception
    }

    private enum SuccessPresentationKind {
        case excellent
        case good
        case needsImprovement
    }

    @EnvironmentObject private var router: AppRouter
    let context: ResultScreenContext
    @State private var showClipPlayer = false

    private var exercise: Exercise {
        Exercise.find(context.exerciseID)
    }

    private var result: AnalysisResult? {
        context.result
    }

    private var displayState: ResultDisplayState {
        guard let result else { return .exception }
        switch result.status {
        case "low_confidence":
            return .lowConfidence
        case "failed":
            return .failed
        default:
            return .success
        }
    }

    private var showsFailureBody: Bool {
        displayState != .success
    }

    private var primaryFeedback: FeedbackItem? {
        result?.feedbacks.first
    }

    private var successPresentationKind: SuccessPresentationKind {
        guard let result, result.status == "success" else { return .needsImprovement }
        if result.feedbacks.isEmpty {
            return .excellent
        }
        if result.feedbacks.allSatisfy({ $0.severity == "info" }) {
            return .good
        }
        return .needsImprovement
    }

    private var feedbackTitle: String {
        switch displayState {
        case .exception, .failed:
            return "分析失败"
        case .lowConfidence:
            return "建议重拍"
        case .success:
            break
        }

        switch successPresentationKind {
        case .excellent:
            return "动作优秀"
        case .good:
            return "动作良好"
        case .needsImprovement:
            break
        }

        return primaryFeedback?.title ?? "动作可改进"
    }

    private var feedbackDescription: String {
        switch displayState {
        case .lowConfidence:
            let reason = result?.lowConfidenceReason?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let reason, reason.isEmpty == false {
                return reason
            }
            return "当前视频不满足拍摄要求，请参考下方拍摄要点重拍"
        case .failed:
            let summary = result?.overallSummary.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return summary.isEmpty ? "本次分析未成功生成结构化结果。" : summary
        case .exception:
            return normalizedFailureDescription(context.failureReason)
        case .success:
            break
        }

        guard let result else {
            return normalizedFailureDescription(context.failureReason)
        }
        return result.overallSummary
    }

    private var trimmedFeedbackDescription: String? {
        let text = feedbackDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private var successIntroDescription: String? {
        if successPresentationKind != .needsImprovement {
            return trimmedFeedbackDescription
        }
        if let primaryProblemDescription {
            return primaryProblemDescription
        }
        return trimmedFeedbackDescription
    }

    private var primaryProblemDescription: String? {
        let text = (primaryFeedback?.description ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private var guidanceCue: String? {
        let cue = (primaryFeedback?.cue ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return cue.isEmpty ? nil : cue
    }

    private var guidanceHowToFix: String? {
        let text = (primaryFeedback?.howToFix ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private var hasGuidanceContent: Bool {
        guard successPresentationKind == .needsImprovement else { return false }
        return guidanceCue != nil || guidanceHowToFix != nil
    }

    private var hasPrimaryProblemContent: Bool {
        guard successPresentationKind == .needsImprovement else { return false }
        return primaryFeedback != nil && (primaryProblemDescription != nil || hasGuidanceContent)
    }

    private var localClipURL: URL? {
        guard let localClipPath = context.localClipPath, localClipPath.isEmpty == false else {
            return nil
        }
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appending(path: localClipPath)
    }

    private var canShowVideoPlayback: Bool {
        result?.status == "success" && hasPrimaryProblemContent && localClipURL != nil
    }

    private var successBadgeTitle: String {
        switch successPresentationKind {
        case .excellent:
            return "优秀"
        case .good:
            return "良好"
        case .needsImprovement:
            return "需改进"
        }
    }

    private var successAccentColor: Color {
        switch successPresentationKind {
        case .excellent:
            return AppTheme.success
        case .good:
            return AppTheme.primary
        case .needsImprovement:
            return AppTheme.warning
        }
    }

    private var shouldShowCaptureGuidanceCard: Bool {
        displayState == .lowConfidence
    }

    private var failureAccentColor: Color {
        switch displayState {
        case .lowConfidence:
            return AppTheme.warning
        case .failed, .exception:
            return AppTheme.textSecondary
        case .success:
            return AppTheme.warning
        }
    }

    private var failureIconName: String {
        switch displayState {
        case .lowConfidence:
            return "camera.viewfinder"
        case .failed, .exception:
            return "xmark.octagon.fill"
        case .success:
            return "exclamationmark.triangle.fill"
        }
    }

    private var failureHeadline: String {
        displayState == .lowConfidence ? "建议重拍" : "分析未成功"
    }

    var body: some View {
        VStack(spacing: 0) {
            AppPageHeader(
                title: "分析结果",
                leadingSystemImage: "chevron.left",
                onLeadingTap: { router.pop() },
                onTrailingTap: nil
            )

            ScrollView(showsIndicators: false) {
                if showsFailureBody {
                    failureBody
                } else {
                    successBody
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
        .sheet(isPresented: $showClipPlayer) {
            if let localClipURL {
                ClipPlayerSheet(videoURL: localClipURL)
            }
        }
    }

    private var failureBody: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Circle()
                    .fill(failureAccentColor.opacity(0.12))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: failureIconName)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(failureAccentColor)
                    }

                Text(failureHeadline)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 12) {
                    if let trimmedFeedbackDescription {
                        Text(trimmedFeedbackDescription)
                            .font(.system(size: 17, weight: .medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.white.opacity(0.88))
                    }

                    Text("本次未成功生成结果，不计入免费分析次数")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(failureAccentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(failureAccentColor.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(failureAccentColor.opacity(0.16), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }

            if shouldShowCaptureGuidanceCard {
                AppCard(cornerRadius: 12) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppTheme.primary)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("拍摄合格性提示")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(AppTheme.primary)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(exercise.guideRequirements, id: \.self) { requirement in
                                    AppBulletText(requirement)
                                }
                            }
                        }
                    }
                }
            }

            VStack(spacing: 12) {
                AppPrimaryButton(title: "重新拍摄", icon: "arrow.clockwise", cornerRadius: 12) {
                    router.replaceTop(with: .guide(exerciseID: exercise.id))
                }

                Button {
                    router.selectTab(.home)
                } label: {
                    Text("返回首页")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(AppTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: 480)
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 120)
    }

    private func normalizedFailureDescription(_ rawReason: String?) -> String {
        let fallback = "当前角度不适合判断，请参考示意图重拍"
        let reason = rawReason?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        switch reason {
        case "":
            return fallback
        case "服务暂时不可用。":
            return "服务暂时不可用，请稍后再试"
        case "服务返回了无法识别的数据。":
            return "服务内部错误"
        case "请先选择一个有效的视频文件。":
            return "请选择有效视频文件"
        default:
            return reason
        }
    }

    private var successBody: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Text(successBadgeTitle)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(successAccentColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(successAccentColor.opacity(0.1))
                    .overlay(
                        Capsule().stroke(successAccentColor.opacity(0.2), lineWidth: 1)
                    )
                    .clipShape(Capsule())

                Text(feedbackTitle)
                    .font(.system(size: 34, weight: .black))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if let successIntroDescription {
                    Text(successIntroDescription)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 24)

            VStack(spacing: 16) {
                if hasGuidanceContent {
                    AppCard(padding: 24, cornerRadius: 16) {
                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb")
                                Text("专业指导")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.primary)
                            .frame(maxWidth: .infinity, alignment: .center)

                            if let guidanceCue {
                                ObliqueQuoteText(
                                    text: "\"\(guidanceCue)\"",
                                    font: .systemFont(ofSize: 18, weight: .semibold),
                                    textColor: UIColor.white.withAlphaComponent(0.92),
                                    alignment: .center,
                                    obliqueness: 0.18
                                )
                                .frame(maxWidth: .infinity)
                            }

                            if let guidanceHowToFix {
                                Text(guidanceHowToFix)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }

                if canShowVideoPlayback {
                    Button {
                        showClipPlayer = true
                    } label: {
                        ZStack {
                            ClipPreviewThumbnailView(videoURL: localClipURL)
                                .overlay(Color.black.opacity(0.34))

                            VStack(spacing: 14) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 64, weight: .regular))
                                    .foregroundStyle(.white.opacity(0.85))

                                Text("点击播放问题片段")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("首要问题片段")
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                }
                                .foregroundStyle(.white)
                                .padding(16)
                            }
                        }
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .background(AppTheme.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.05), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: 480)
            .padding(.horizontal, 24)

            VStack(spacing: 16) {
                if context.source == .analysis {
                    AppPrimaryButton(
                        title: "查看历史记录",
                        icon: "clock.arrow.circlepath",
                        cornerRadius: 12
                    ) {
                        router.selectTab(.history)
                    }
                }

                Button {
                    if context.source == .history {
                        router.selectTab(.history)
                    } else {
                        router.replaceTop(with: .analyzing(exerciseID: exercise.id))
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: context.source == .history ? "list.bullet" : "arrow.clockwise")
                            .foregroundStyle(AppTheme.primary)
                        Text(context.source == .history ? "返回记录列表" : "重新分析")
                    }
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .background(AppTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: 480)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
    }
}

private struct ClipPlayerSheet: View {
    private struct PlaybackRateOption: Identifiable, Hashable {
        let value: Float
        let label: String

        var id: String { label }
    }

    private static let playbackRates: [PlaybackRateOption] = [
        PlaybackRateOption(value: 0.25, label: "0.25x"),
        PlaybackRateOption(value: 0.5, label: "0.5x"),
        PlaybackRateOption(value: 1.0, label: "1x"),
        PlaybackRateOption(value: 1.25, label: "1.25x"),
        PlaybackRateOption(value: 1.5, label: "1.5x"),
    ]

    let videoURL: URL
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    @State private var playbackRate: Float = 1.0
    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    @State private var isScrubbing = false
    @State private var timeObserver: Any?
    @State private var endObserver: Any?
    @State private var didReachEnd = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                ZStack {
                    PlayerLayerContainer(player: player)
                        .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 0) {
                        HStack {
                            Spacer()

                            HStack(spacing: 12) {
                                Menu {
                                    ForEach(Self.playbackRates) { option in
                                        Button {
                                            setPlaybackRate(option.value)
                                        } label: {
                                            HStack {
                                                Text(option.label)
                                                if playbackRate == option.value {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text("倍速")
                                        Text(selectedPlaybackRateLabel)
                                            .foregroundStyle(.white.opacity(0.7))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(Capsule())
                                }

                                Button("完成") {
                                    closePlayer()
                                }
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                        Spacer()

                        HStack(spacing: 32) {
                            transportButton(systemImage: "gobackward.10") {
                                seek(by: -10)
                            }

                            Button {
                                togglePlayback()
                            } label: {
                                Image(systemName: centerControlIcon)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 74, height: 74)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            transportButton(systemImage: "goforward.10") {
                                seek(by: 10)
                            }
                        }

                        VStack(spacing: 10) {
                            progressBar

                            HStack {
                                Text(formattedTime(currentTime))
                                Spacer()
                                Text(formattedTime(duration))
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.82))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 28)
                        .background(
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.65)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .onAppear {
                    player.seek(to: .zero)
                    startPlayback()
                }
            } else {
                ProgressView("正在加载片段…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black)
            }
        }
        .task {
            await configurePlayerIfNeeded()
        }
        .onDisappear {
            tearDownPlayer()
        }
    }

    private var selectedPlaybackRateLabel: String {
        Self.playbackRates.first(where: { $0.value == playbackRate })?.label ?? "1x"
    }

    private var centerControlIcon: String {
        if didReachEnd {
            return "arrow.clockwise"
        }
        return isPlaying ? "pause.fill" : "play.fill"
    }

    private var progressFraction: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    private func configurePlayerIfNeeded() async {
        guard player == nil else { return }

        let item = AVPlayerItem(url: videoURL)
        let player = AVPlayer(playerItem: item)
        self.player = player

        duration = await assetDurationSeconds(for: item.asset)
        addTimeObserver(to: player)
        addEndObserver(for: item)
    }

    private func addTimeObserver(to player: AVPlayer) {
        guard timeObserver == nil else { return }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600),
            queue: .main
        ) { time in
            Task { @MainActor in
                guard isScrubbing == false else { return }
                currentTime = max(time.seconds.isFinite ? time.seconds : 0, 0)
                if didReachEnd && currentTime < duration {
                    didReachEnd = false
                }
                if let itemDuration = player.currentItem?.duration.seconds, itemDuration.isFinite, itemDuration > 0 {
                    duration = itemDuration
                }
            }
        }
    }

    private func removeTimeObserver() {
        guard let player, let timeObserver else { return }
        player.removeTimeObserver(timeObserver)
        self.timeObserver = nil
    }

    private func addEndObserver(for item: AVPlayerItem) {
        removeEndObserver()
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            Task { @MainActor in
                isPlaying = false
                didReachEnd = true
                if duration > 0 {
                    currentTime = duration
                }
            }
        }
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    private func startPlayback() {
        guard let player else { return }
        didReachEnd = false
        player.playImmediately(atRate: playbackRate)
        isPlaying = true
    }

    private func togglePlayback() {
        guard player != nil else { return }

        if didReachEnd {
            seek(to: 0)
            startPlayback()
            return
        }

        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            startPlayback()
        }
    }

    private func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        guard let player else { return }
        if isPlaying {
            player.rate = rate
        }
    }

    private func seek(by delta: Double) {
        let target = min(max(currentTime + delta, 0), duration)
        seek(to: target)
    }

    private func seek(to seconds: Double) {
        guard let player else { return }
        let clamped = min(max(seconds, 0), duration)
        let time = CMTime(seconds: clamped, preferredTimescale: 600)
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = clamped
        didReachEnd = clamped >= duration && duration > 0
    }

    private func closePlayer() {
        tearDownPlayer()
        dismiss()
    }

    private func tearDownPlayer() {
        player?.pause()
        removeTimeObserver()
        removeEndObserver()
        isPlaying = false
        didReachEnd = false
    }

    private func assetDurationSeconds(for asset: AVAsset) async -> Double {
        do {
            let loadedDuration = try await asset.load(.duration)
            let seconds = loadedDuration.seconds
            return max(seconds.isFinite ? seconds : 0, 0)
        } catch {
            return 0
        }
    }

    private func transportButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(Color.black.opacity(0.42))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }

    private func formattedTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "00:00" }
        let total = max(Int(seconds.rounded(.down)), 0)
        let minutes = total / 60
        let remainingSeconds = total % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let knobCenterX = max(6, min(width - 6, width * progressFraction))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(height: 4)

                Capsule()
                    .fill(.white)
                    .frame(width: max(4, width * progressFraction), height: 4)

                Circle()
                    .fill(.white)
                    .frame(width: 12, height: 12)
                    .offset(x: knobCenterX - 6)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isScrubbing = true
                        let location = min(max(value.location.x, 0), width)
                        let seconds = duration > 0 ? (location / max(width, 1)) * duration : 0
                        currentTime = seconds
                    }
                    .onEnded { value in
                        let location = min(max(value.location.x, 0), width)
                        let seconds = duration > 0 ? (location / max(width, 1)) * duration : 0
                        seek(to: seconds)
                        isScrubbing = false
                    }
            )
        }
        .frame(height: 14)
    }
}

private struct ClipPreviewThumbnailView: View {
    let videoURL: URL?

    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(AppTheme.cardMuted)
            }
        }
        .clipped()
        .task(id: videoURL) {
            thumbnail = await loadThumbnail(from: videoURL)
        }
    }

    private func loadThumbnail(from url: URL?) async -> UIImage? {
        guard let url else { return nil }

        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let asset = AVURLAsset(url: url)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 1200, height: 1200)
                generator.requestedTimeToleranceBefore = .zero
                generator.requestedTimeToleranceAfter = .zero

                let times = [
                    NSValue(time: .zero),
                    NSValue(time: CMTime(seconds: 0.1, preferredTimescale: 600)),
                    NSValue(time: CMTime(seconds: 0.2, preferredTimescale: 600)),
                ]

                for time in times {
                    if let cgImage = try? generator.copyCGImage(at: time.timeValue, actualTime: nil) {
                        continuation.resume(returning: UIImage(cgImage: cgImage))
                        return
                    }
                }

                continuation.resume(returning: nil)
            }
        }
    }
}

private struct PlayerLayerContainer: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerLayerView {
        let view = PlayerLayerView()
        view.playerLayer.videoGravity = .resizeAspect
        view.playerLayer.player = player
        return view
    }

    func updateUIView(_ uiView: PlayerLayerView, context: Context) {
        uiView.playerLayer.player = player
    }
}

private final class PlayerLayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }

    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
}

private struct ObliqueQuoteText: UIViewRepresentable {
    let text: String
    let font: UIFont
    let textColor: UIColor
    let alignment: NSTextAlignment
    let obliqueness: CGFloat

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    func updateUIView(_ label: UILabel, context: Context) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment

        label.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: textColor,
                .obliqueness: obliqueness,
                .paragraphStyle: paragraphStyle,
            ]
        )
    }
}
