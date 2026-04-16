import SwiftUI
import WinTrainStoreKitSupport

struct PaywallView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @State private var statusMessage: String?
    @State private var isWorking = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    hero
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    freeRuleCard
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    featureList
                        .padding(.horizontal, 24)
                        .padding(.top, 12)

                    pricingCard
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

                    if let statusMessage {
                        AppCard(cornerRadius: 16) {
                            Text(statusMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }

                    footerLinks
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
        .task {
            await environment.storeKitCoordinator.loadProducts()
        }
    }

    private var header: some View {
        HStack {
            Button {
                router.pop()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

            Text("解锁专业版")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            Color.clear.frame(width: 48, height: 48)
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            AppRemoteImage(assetName: "PaywallHero")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    LinearGradient(
                        colors: [.clear, AppTheme.background.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("获取更多动作纠错反馈")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(.white)
                Text("AI 实时指导，让每一次训练更专业")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
            }
            .padding(24)
        }
        .frame(height: 220)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.45), radius: 20, y: 8)
    }

    private var freeRuleCard: some View {
        AppCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                    Text("免费版使用规则")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.9))
                }

                HStack(spacing: 0) {
                    quotaColumn(title: "每日额度", value: "1 次成功分析")

                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 1)

                    quotaColumn(title: "累计限额", value: "共 3 次成功分析")
                        .padding(.leading, 12)
                }

                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)

                Text("* 仅计入分析成功的次数，识别失败不扣除额度")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .italic()
            }
        }
    }

    private var featureList: some View {
        VStack(spacing: 0) {
            ForEach([
                ("无限次 AI 分析", "解除每日及累计限制，随时随地纠错"),
                ("完整训练历史", "永久保存所有分析数据与视频回顾"),
                ("专业动作库解锁", "支持深蹲、硬拉等 30+ 种高阶动作"),
            ], id: \.0) { feature in
                HStack(alignment: .top, spacing: 14) {
                    Circle()
                        .fill(AppTheme.primary.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .black))
                                .foregroundStyle(AppTheme.primary)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.0)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                        Text(feature.1)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()
                }
                .padding(.vertical, 16)

                if feature.0 != "专业动作库解锁" {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                }
            }
        }
    }

    private var pricingCard: some View {
        ZStack(alignment: .topTrailing) {
            AppCard(padding: 24, cornerRadius: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("专业版月度订阅")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(.white)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("¥28.00")
                            .font(.system(size: 48, weight: .black))
                            .foregroundStyle(AppTheme.primary)
                            .shadow(color: AppTheme.primary.opacity(0.4), radius: 12)
                        Text("/ 月")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .tracking(1.6)
                            .textCase(.uppercase)
                    }

                    AppPrimaryButton(
                        title: isWorking ? "处理中..." : "立即开启无限分析",
                        icon: nil,
                        isDisabled: isWorking,
                        cornerRadius: 12,
                        foreground: AppTheme.background
                    ) {
                        Task { await purchase() }
                    }
                    .padding(.top, 8)

                    Text("订阅将自动续订，您可以随时在应用设置中取消")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.primary, lineWidth: 2)
            )
            .shadow(color: AppTheme.primary.opacity(0.15), radius: 20, y: 8)

            Text("MVP 期间特惠")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(AppTheme.background)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(AppTheme.primary)
                .clipShape(Capsule())
                .offset(x: -24, y: -12)
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 28) {
            Button("服务条款") {}
            Button("隐私政策") {}
            Button("恢复购买") {
                Task { await restore() }
            }
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(Color.gray.opacity(0.7))
        .textCase(.uppercase)
        .tracking(1.2)
    }

    private func quotaColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .tracking(1.2)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func purchase() async {
        isWorking = true
        defer { isWorking = false }

        await environment.storeKitCoordinator.loadProducts()
        await environment.storeKitCoordinator.purchaseMonthlyPlan()

        guard
            let originalID = environment.storeKitCoordinator.latestTransactionOriginalID,
            let signedTransaction = environment.storeKitCoordinator.latestSignedTransaction
        else {
            statusMessage = environment.storeKitCoordinator.statusMessage
            return
        }

        do {
            let result = try await environment.subscriptionService.activate(
                productID: StoreKitCoordinator.monthlyProductID,
                originalTransactionID: String(originalID),
                signedTransactionInfo: signedTransaction
            )
            statusMessage = "购买成功，当前状态：\(result.subscription.status)"
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func restore() async {
        isWorking = true
        defer { isWorking = false }

        await environment.storeKitCoordinator.restorePurchases()
        guard let originalID = environment.storeKitCoordinator.latestTransactionOriginalID else {
            statusMessage = environment.storeKitCoordinator.statusMessage
            return
        }

        do {
            let result = try await environment.subscriptionService.restore(originalTransactionID: String(originalID))
            statusMessage = "恢复购买完成，当前状态：\(result.subscription.status)"
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
