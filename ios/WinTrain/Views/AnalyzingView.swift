import AVFoundation
import SwiftUI
import UIKit

struct AnalyzingView: View {
    private enum ProgressConfig {
        static let tickIntervalSeconds = 0.18
    }

    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    let exercise: Exercise
    @ObservedObject var flowViewModel: AnalysisFlowViewModel
    @State private var displayProgress = 0.0
    @State private var didStart = false
    @State private var didStartScanAnimation = false
    @State private var scanBandPosition = 0.0

    private var viewportHeight: CGFloat {
        min(max(UIScreen.main.bounds.height * 0.42, 320), 410)
    }

    private var estimatedRemainingSeconds: Int {
        max(1, Int((1 - displayProgress) * environment.analysisEstimatedDurationSeconds))
    }

    private var simulatedProgressStep: Double {
        let estimate = max(environment.analysisEstimatedDurationSeconds, 1)
        return ProgressConfig.tickIntervalSeconds / estimate
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                header(topInset: proxy.safeAreaInsets.top)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        analyzingViewport

                        VStack(spacing: 8) {
                            Text("AI 正在分析动作细节...")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            Text("预计还需 \(estimatedRemainingSeconds) 秒")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("分析进度")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text("\(Int(displayProgress * 100))%")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(AppTheme.primary)
                            }

                            GeometryReader { progressProxy in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.1))
                                    Capsule()
                                        .fill(AppTheme.primary)
                                        .frame(width: progressProxy.size.width * displayProgress)
                                }
                            }
                            .frame(height: 10)

                            HStack(spacing: 8) {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundStyle(AppTheme.primary)
                                Text("正在识别关节角度与身体力线")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(AppTheme.primary.opacity(0.7))
                            }
                        }

                        HStack(spacing: 16) {
                            AppMetricTile(title: "关键帧提取", value: "\(max(1, Int(displayProgress * 18)))/18")
                            AppMetricTile(title: "采样频率", value: "60 FPS")
                        }
                        .padding(.top, 4)

                        Button {
                            cancelAnalysis()
                        } label: {
                            Text("取消分析")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.white)
                                .background(Color.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppSurfaceBackground())
            .task {
                await beginFlowIfNeeded()
            }
        }
    }

    private func header(topInset: CGFloat) -> some View {
        HStack {
            AppIconButton(systemImage: "chevron.left", tint: .white, action: cancelAnalysis)

            Text("动作分析")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, max(topInset, 0) + 8)
        .padding(.bottom, 8)
        .background(AppTheme.background.opacity(0.98))
    }

    private var analyzingViewport: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { proxy in
                ZStack {
                    AnalysisPreviewThumbnailView(
                        videoURL: flowViewModel.selectedVideoURL,
                        fallbackAssetName: exercise.imageAssetName
                    )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.16),
                                    Color.clear,
                                    Color.black.opacity(0.42),
                                    Color.black.opacity(0.66),
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Color.clear
                        .overlay(scanOverlay(proxy: proxy))
                }
            }

            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.primary)
                    .frame(width: 8, height: 8)
                Text("LIVE ANALYSIS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(AppTheme.primary)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.primary.opacity(0.2))
            .overlay(
                Capsule().stroke(AppTheme.primary.opacity(0.3), lineWidth: 1)
            )
            .clipShape(Capsule())
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewportHeight)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.35), radius: 20, y: 8)
        .onAppear {
            startScanAnimationIfNeeded()
        }
    }

    @ViewBuilder
    private func scanOverlay(proxy: GeometryProxy) -> some View {
        let width = proxy.size.width
        let height = proxy.size.height
        let scanY = height * scanBandPosition

        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        AppTheme.primary.opacity(0),
                        AppTheme.primary.opacity(0.14),
                        AppTheme.primary.opacity(0.5),
                        AppTheme.primary.opacity(0.82),
                        AppTheme.primary.opacity(0.5),
                        AppTheme.primary.opacity(0.14),
                        AppTheme.primary.opacity(0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: width, height: 148)
            .overlay(alignment: .center) {
                Rectangle()
                    .fill(AppTheme.primary.opacity(0.9))
                    .frame(width: width, height: 2)
                    .shadow(color: AppTheme.primary.opacity(0.9), radius: 18)
            }
            .offset(y: scanY - (height / 2))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func beginFlowIfNeeded() async {
        guard didStart == false else { return }
        didStart = true

        async let progressTask: Void = animateProgress()
        flowViewModel.resetResult()
        await flowViewModel.submit()
        _ = await progressTask

        await MainActor.run {
            displayProgress = 1
        }

        try? await Task.sleep(for: .milliseconds(250))
        if let result = flowViewModel.latestResult {
            router.replaceTop(with: .result(.analysis(
                result: result,
                exerciseID: exercise.id,
                localClipPath: flowViewModel.latestClipPath
            )))
        } else {
            router.replaceTop(with: .result(.failure(exerciseID: exercise.id, reason: flowViewModel.errorMessage)))
        }
    }

    private func animateProgress() async {
        while displayProgress < 0.92 && flowViewModel.latestResult == nil && flowViewModel.errorMessage == nil {
            try? await Task.sleep(for: .milliseconds(180))
            await MainActor.run {
                let target = max(displayProgress + simulatedProgressStep, flowViewModel.uploadProgress)
                displayProgress = min(0.92, target)
            }
        }
    }

    private func cancelAnalysis() {
        flowViewModel.resetFlow()
        router.selectTab(.home)
    }

    private func startScanAnimationIfNeeded() {
        guard didStartScanAnimation == false else { return }
        didStartScanAnimation = true
        scanBandPosition = 0.0

        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: true)) {
            scanBandPosition = 1.0
        }
    }
}

private struct AnalysisPreviewThumbnailView: View {
    let videoURL: URL?
    let fallbackAssetName: String

    @State private var thumbnail: UIImage?

    var body: some View {
        Group {
            if let thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                AppRemoteImage(assetName: fallbackAssetName)
            }
        }
        .clipped()
        .task(id: videoURL) {
            thumbnail = await loadThumbnail(from: videoURL)
        }
    }

    private func loadThumbnail(from url: URL?) async -> UIImage? {
        guard let url else { return nil }

        let accessedSecurityScopedResource = url.startAccessingSecurityScopedResource()
        defer {
            if accessedSecurityScopedResource {
                url.stopAccessingSecurityScopedResource()
            }
        }

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
