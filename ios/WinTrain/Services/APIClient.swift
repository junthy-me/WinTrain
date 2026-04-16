import Foundation
import os

struct APIClient {
    let baseURL: URL
    private let session: URLSession = .shared
    private static let logger = Logger(subsystem: "com.wintrain.app", category: "network")

    func fetchQuota(installID: String) async throws -> QuotaSnapshot {
        var request = URLRequest(url: baseURL.appending(path: "/v1/quota"))
        request.setValue(installID, forHTTPHeaderField: "X-Install-ID")
        let (data, response) = try await session.data(for: request)
        logResponse(for: request, response: response, data: data)
        try validate(response: response, data: data)
        do {
            return try JSONDecoder().decode(QuotaSnapshot.self, from: data)
        } catch {
            logDecodeFailure(for: request, data: data, error: error)
            throw error
        }
    }

    func uploadAnalysis(installID: String, exerciseID: String, videoURL: URL) async throws -> AnalysisResult {
        var request = URLRequest(url: baseURL.appending(path: "/v1/analysis"))
        request.httpMethod = "POST"
        request.setValue(installID, forHTTPHeaderField: "X-Install-ID")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try multipartBody(boundary: boundary, exerciseID: exerciseID, videoURL: videoURL)

        let (data, response) = try await session.data(for: request)
        logResponse(for: request, response: response, data: data)
        try validate(response: response, data: data)
        do {
            return try JSONDecoder().decode(AnalysisResult.self, from: data)
        } catch {
            logDecodeFailure(for: request, data: data, error: error)
            throw error
        }
    }

    func activateSubscription(installID: String, productID: String, originalTransactionID: String, signedTransactionInfo: String) async throws -> SubscriptionResult {
        try await postJSON(
            path: "/v1/subscription/activate",
            installID: installID,
            body: [
                "product_id": productID,
                "original_transaction_id": originalTransactionID,
                "signed_transaction_info": signedTransactionInfo,
            ]
        )
    }

    func restoreSubscription(installID: String, originalTransactionID: String) async throws -> SubscriptionResult {
        try await postJSON(
            path: "/v1/subscription/restore",
            installID: installID,
            body: [
                "original_transaction_id": originalTransactionID,
            ]
        )
    }

    private func postJSON<T: Decodable>(path: String, installID: String, body: [String: String]) async throws -> T {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(installID, forHTTPHeaderField: "X-Install-ID")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        logResponse(for: request, response: response, data: data)
        try validate(response: response, data: data)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            logDecodeFailure(for: request, data: data, error: error)
            throw error
        }
    }

    private func multipartBody(boundary: String, exerciseID: String, videoURL: URL) throws -> Data {
        guard let videoData = try? Data(contentsOf: videoURL) else {
            throw AppError.invalidVideo
        }

        var body = Data()
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"exercise_id\"\r\n\r\n")
        body.appendString("\(exerciseID)\r\n")
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"video\"; filename=\"\(videoURL.lastPathComponent)\"\r\n")
        body.appendString("Content-Type: video/mp4\r\n\r\n")
        body.append(videoData)
        body.appendString("\r\n--\(boundary)--\r\n")
        return body
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200 ..< 300:
            return
        default:
            if let errorPayload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorPayload["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw AppError.server(message)
            }
            throw AppError.server("服务暂时不可用。")
        }
    }

    private func logResponse(for request: URLRequest, response: URLResponse, data: Data) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<missing-url>"
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
        let bodyPreview = previewString(for: data)

        Self.logger.info(
            """
            API response
            method=\(method, privacy: .public)
            url=\(url, privacy: .public)
            status=\(statusCode, privacy: .public)
            body=\(bodyPreview, privacy: .public)
            """
        )
    }

    private func logDecodeFailure(for request: URLRequest, data: Data, error: Error) {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<missing-url>"
        let bodyPreview = previewString(for: data)

        Self.logger.error(
            """
            API decode failed
            method=\(method, privacy: .public)
            url=\(url, privacy: .public)
            error=\(error.localizedDescription, privacy: .public)
            body=\(bodyPreview, privacy: .public)
            """
        )
    }

    private func previewString(for data: Data) -> String {
        guard data.isEmpty == false else { return "<empty>" }

        let text = String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count) bytes>"
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count > 2000 {
            return String(trimmed.prefix(2000)) + "...<truncated>"
        }
        return trimmed.isEmpty ? "<empty>" : trimmed
    }
}

private extension Data {
    mutating func appendString(_ value: String) {
        append(Data(value.utf8))
    }
}
