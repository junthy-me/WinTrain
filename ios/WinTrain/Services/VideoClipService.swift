import AVFoundation
import Foundation

enum VideoClipError: LocalizedError {
    case invalidTimeRange
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidTimeRange:
            return "无法生成有效的视频片段。"
        case .exportFailed(let reason):
            return reason
        }
    }
}

struct VideoClipService {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func exportPrimaryClip(from sourceURL: URL, clip: ClipRange, sessionID: String) async throws -> URL {
        let asset = AVURLAsset(url: sourceURL)
        let assetDuration = try await asset.load(.duration)
        let assetDurationSeconds = CMTimeGetSeconds(assetDuration)

        guard assetDurationSeconds.isFinite, assetDurationSeconds > 0 else {
            throw VideoClipError.invalidTimeRange
        }

        let startSeconds = max(Double(clip.startMS) / 1000, 0)
        let endSeconds = min(Double(clip.endMS) / 1000, assetDurationSeconds)

        guard endSeconds > startSeconds else {
            throw VideoClipError.invalidTimeRange
        }

        let clipDirectory = try ensureDirectory(named: "Clips")
        let outputURL = clipDirectory.appending(path: "\(sessionID)-primary.mp4")
        try? fileManager.removeItem(at: outputURL)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            throw VideoClipError.exportFailed("当前设备无法创建视频导出会话。")
        }

        let requestedFileType: AVFileType = exportSession.supportedFileTypes.contains(.mp4) ? .mp4 : .mov
        let actualOutputURL: URL
        if requestedFileType == .mov {
            actualOutputURL = clipDirectory.appending(path: "\(sessionID)-primary.mov")
            try? fileManager.removeItem(at: actualOutputURL)
        } else {
            actualOutputURL = outputURL
        }

        exportSession.outputURL = actualOutputURL
        exportSession.outputFileType = requestedFileType
        exportSession.timeRange = CMTimeRange(
            start: CMTime(seconds: startSeconds, preferredTimescale: 600),
            end: CMTime(seconds: endSeconds, preferredTimescale: 600)
        )
        exportSession.shouldOptimizeForNetworkUse = true

        try await export(exportSession)
        return actualOutputURL
    }

    private func export(_ session: AVAssetExportSession) async throws {
        await session.export()

        switch session.status {
        case .completed:
            return
        case .failed:
            throw VideoClipError.exportFailed(session.error?.localizedDescription ?? "视频片段导出失败。")
        case .cancelled:
            throw VideoClipError.exportFailed("视频片段导出已取消。")
        default:
            throw VideoClipError.exportFailed("视频片段导出未完成。")
        }
    }

    private func ensureDirectory(named directoryName: String) throws -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = baseDirectory.appending(path: "WinTrain", directoryHint: .isDirectory)
        let destinationDirectory = appDirectory.appending(path: directoryName, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        return destinationDirectory
    }
}
