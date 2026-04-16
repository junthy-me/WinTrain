import Foundation

struct ImportedVideoStore {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func importVideo(from sourceURL: URL) throws -> URL {
        let destinationDirectory = try ensureDirectory(named: "ImportedVideos")
        let fileExtension = sourceURL.pathExtension.isEmpty ? "mp4" : sourceURL.pathExtension
        let destinationURL = destinationDirectory.appending(path: "\(UUID().uuidString).\(fileExtension)")

        let requiresScopedAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if requiresScopedAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    func removeImportedVideo(at url: URL?) {
        guard let url else { return }
        try? fileManager.removeItem(at: url)
    }

    private func ensureDirectory(named directoryName: String) throws -> URL {
        let baseDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = baseDirectory.appending(path: "WinTrain", directoryHint: .isDirectory)
        let destinationDirectory = appDirectory.appending(path: directoryName, directoryHint: .isDirectory)
        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        return destinationDirectory
    }
}
