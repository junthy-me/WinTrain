import Combine
import Foundation
import StoreKit

@MainActor
public final class StoreKitCoordinator: ObservableObject {
    public nonisolated static let monthlyProductID = "wintrain.pro.monthly"

    @Published public private(set) var products: [Product] = []
    @Published public private(set) var isSubscribed = false
    @Published public private(set) var latestTransactionOriginalID: UInt64?
    @Published public private(set) var latestSignedTransaction: String?
    @Published public private(set) var statusMessage: String?

    private var updatesTask: Task<Void, Never>?

    public init() {
        updatesTask = observeTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    public func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.monthlyProductID])
            if products.isEmpty {
                statusMessage = "没有找到可售订阅产品。请确认 Scheme 已挂载本地 StoreKit 配置，或 App Store Connect 产品已同步。"
            } else {
                statusMessage = "已加载 \(products.count) 个订阅产品。"
            }
            await refreshCurrentEntitlements()
        } catch {
            statusMessage = "加载订阅产品失败：\(error.localizedDescription)"
        }
    }

    public func purchaseMonthlyPlan() async {
        if products.isEmpty {
            await loadProducts()
        }
        guard let product = products.first(where: { $0.id == Self.monthlyProductID }) else {
            statusMessage = "本地 StoreKit 环境中没有 \(Self.monthlyProductID) 产品。"
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                let transaction = try checkVerified(verificationResult)
                latestTransactionOriginalID = transaction.originalID
                latestSignedTransaction = String(data: transaction.jsonRepresentation, encoding: .utf8)
                isSubscribed = true
                statusMessage = "购买成功。originalTransactionId=\(transaction.originalID)"
                await transaction.finish()
            case .userCancelled:
                statusMessage = "用户取消了购买。"
            case .pending:
                statusMessage = "购买处于待处理状态。"
            @unknown default:
                statusMessage = "遇到了未知购买结果。"
            }
        } catch {
            statusMessage = "购买失败：\(error.localizedDescription)"
        }
    }

    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshCurrentEntitlements()
            statusMessage = isSubscribed ? "恢复购买完成，当前订阅有效。" : "恢复购买完成，但未找到有效订阅。"
        } catch {
            statusMessage = "恢复购买失败：\(error.localizedDescription)"
        }
    }

    public func refreshCurrentEntitlements() async {
        var activeSubscription = false
        var originalID: UInt64?

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            guard transaction.productID == Self.monthlyProductID else {
                continue
            }
            if transaction.revocationDate == nil {
                activeSubscription = true
                originalID = transaction.originalID
            }
        }

        isSubscribed = activeSubscription
        latestTransactionOriginalID = originalID
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            guard let self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    if transaction.productID == Self.monthlyProductID {
                        await self.refreshCurrentEntitlements()
                        self.statusMessage = "收到订阅更新：\(transaction.productID)"
                    }
                    await transaction.finish()
                } catch {
                    self.statusMessage = "收到未验证交易：\(error.localizedDescription)"
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw StoreKitCoordinatorError.failedVerification
        }
    }
}

enum StoreKitCoordinatorError: Error, LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "交易验证失败。"
        }
    }
}
