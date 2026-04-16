import SwiftUI
import UniformTypeIdentifiers

struct GuideView: View {
    private enum Layout {
        static let sectionIconSize: CGFloat = 30
        static let sectionIconGlyphSize: CGFloat = 14
    }

    @EnvironmentObject private var router: AppRouter
    let exercise: Exercise
    @ObservedObject var flowViewModel: AnalysisFlowViewModel
    @State private var isImporting = false
    @State private var pickerSource: VideoCapturePicker.Source?
    @State private var showFullImage = false
    @State private var showSourceDialog = false

    private var cameraHeight: String {
        exercise.id == "squat" ? "髋部附近高度" : "上半身到头部附近高度"
    }

    private var requirements: [String] {
        if exercise.id == "squat" {
            return [
                "能看到杠铃、躯干、髋、膝、踝、脚",
                "能观察杠铃路径与身体稳定性",
                "能看到完整下蹲和站起过程",
            ]
        }

        return [
            "能看到头、肩、肘、杆、躯干",
            "能观察到身体是否后仰",
            "能看到下拉到底与放回过程",
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = max(proxy.size.width - 48, 0)

            VStack(spacing: 0) {
                AppPageHeader(
                    title: "拍摄指南",
                    leadingSystemImage: "chevron.left",
                    onLeadingTap: { router.pop() },
                    onTrailingTap: nil
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(exercise.name)拍摄要点")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(.white)
                            Text("只需 3 步，确保动作分析精准无误。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Button {
                            showFullImage = true
                        } label: {
                            ZStack(alignment: .bottomLeading) {
                                AppRemoteImage(assetName: exercise.imageAssetName)
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(16 / 9, contentMode: .fit)
                                    .overlay(
                                        LinearGradient(
                                            colors: [.clear, AppTheme.background.opacity(0.6)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 11, weight: .bold))
                                    Text("点击放大")
                                        .font(.system(size: 10, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.primary.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
                                .padding(12)
                            }
                            .background(AppTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        VStack(spacing: 16) {
                            guideBlock(icon: "camera.fill", title: "推荐机位与高度") {
                                VStack(alignment: .leading, spacing: 4) {
                                    guideDetailRow(label: "机位", value: exercise.view)
                                    guideDetailRow(label: "高度", value: cameraHeight)
                                }
                            }

                            guideBlock(icon: "viewfinder", title: "画面要求") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(requirements, id: \.self) { item in
                                        AppBulletText(item, color: AppTheme.textSecondary)
                                    }
                                }
                            }
                        }

                        AppCard(cornerRadius: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "info.circle")
                                    Text("通用引导原则")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)

                                ForEach([
                                    "机位固定，不手持",
                                    "尽量拍到全身与器械关键部位",
                                    "光线充足，不要被路人遮挡",
                                ], id: \.self) { item in
                                    AppBulletText(item, color: AppTheme.textSecondary, size: 5)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        AppPrimaryButton(title: "开始拍摄", icon: "video.fill", cornerRadius: 16) {
                            showSourceDialog = true
                        }
                    }
                    .frame(width: contentWidth, alignment: .topLeading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
        .confirmationDialog("选择视频来源", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("录制新视频") {
                pickerSource = .camera
            }
            Button("从相册选择视频") {
                pickerSource = .library
            }
            Button("选择本地视频文件") {
                isImporting = true
            }
            Button("使用示例视频路径") {
                let demoURL = URL(fileURLWithPath: "/tmp/\(exercise.id).mp4")
                handlePickedVideo(demoURL)
            }
            Button("取消", role: .cancel) {}
        }
        .sheet(item: Binding(
            get: { pickerSource.map(PickerSourceWrapper.init(source:)) },
            set: { pickerSource = $0?.source }
        )) { wrapper in
            VideoCapturePicker(source: wrapper.source) { url in
                handlePickedVideo(url)
                pickerSource = nil
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.movie, .mpeg4Movie, .quickTimeMovie]
        ) { result in
            switch result {
            case .success(let url):
                handlePickedVideo(url)
            case .failure(let error):
                flowViewModel.errorMessage = error.localizedDescription
            }
        }
        .fullScreenCover(isPresented: $showFullImage) {
            ZoomableGuideImageView(
                assetName: exercise.imageAssetName,
                onClose: { showFullImage = false }
            )
        }
    }

    private func guideBlock<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppTheme.primary.opacity(0.2))
                    .frame(width: Layout.sectionIconSize, height: Layout.sectionIconSize)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: Layout.sectionIconGlyphSize, weight: .semibold))
                            .foregroundStyle(AppTheme.primary)
                    }

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(AppTheme.card.opacity(0.5))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func guideDetailRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(label)：")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }

    private func handlePickedVideo(_ url: URL) {
        flowViewModel.prepare(exercise: exercise, videoURL: url)
        router.push(.analyzing(exerciseID: exercise.id))
    }
}

private struct PickerSourceWrapper: Identifiable {
    let id = UUID()
    let source: VideoCapturePicker.Source
}

private struct ZoomableGuideImageView: View {
    private static let maxScale: CGFloat = 4

    let assetName: String?
    let onClose: () -> Void

    @State private var steadyScale: CGFloat = 1
    @State private var pinchScale: CGFloat = 1
    @State private var steadyOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

    private var currentScale: CGFloat {
        min(max(steadyScale * pinchScale, 1), Self.maxScale)
    }

    private var currentOffset: CGSize {
        CGSize(
            width: steadyOffset.width + dragOffset.width,
            height: steadyOffset.height + dragOffset.height
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topTrailing) {
                Color.black.opacity(0.94)
                    .ignoresSafeArea()
                    .onTapGesture(count: 2, perform: toggleZoom)

                AppRemoteImage(assetName: assetName, contentMode: .fit)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(currentScale)
                    .offset(currentOffset)
                    .gesture(combinedGesture)
                    .onTapGesture(count: 2, perform: toggleZoom)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
        }
    }

    private var combinedGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    pinchScale = value
                }
                .onEnded { value in
                    steadyScale = min(max(steadyScale * value, 1), Self.maxScale)
                    pinchScale = 1
                    if steadyScale == 1 {
                        steadyOffset = .zero
                        dragOffset = .zero
                    }
                },
            DragGesture()
                .onChanged { value in
                    guard currentScale > 1 else {
                        dragOffset = .zero
                        return
                    }
                    dragOffset = value.translation
                }
                .onEnded { value in
                    guard currentScale > 1 else {
                        steadyOffset = .zero
                        dragOffset = .zero
                        return
                    }
                    steadyOffset.width += value.translation.width
                    steadyOffset.height += value.translation.height
                    dragOffset = .zero
                }
        )
    }

    private func toggleZoom() {
        if steadyScale > 1 {
            steadyScale = 1
            pinchScale = 1
            steadyOffset = .zero
            dragOffset = .zero
        } else {
            steadyScale = 2
        }
    }
}
