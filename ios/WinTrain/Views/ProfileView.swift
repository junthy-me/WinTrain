import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter

    private var isPro: Bool {
        environment.quotaStore.snapshot?.isPro == true || environment.storeKitCoordinator.isSubscribed
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        AppBrandLockup(titleSize: 30, subtitleSize: 13)

                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(isPro ? AppTheme.primary : AppTheme.textSecondary)
                            Text(isPro ? "已开通专业版" : "未开通专业版")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(isPro ? AppTheme.primary : AppTheme.textSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.05))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    .padding(.top, 4)

                    AppCard(padding: 0, cornerRadius: 16) {
                        VStack(spacing: 0) {
                            profileRow(icon: "crown", title: "订阅专业版", highlight: !isPro) {
                                router.push(.paywall)
                            }
                            profileRow(icon: "questionmark.circle", title: "帮助与反馈") {
                                router.push(.helpFeedback)
                            }
                            profileRow(icon: "shield.lefthalf.filled", title: "隐私说明", showsDivider: false) {
                                router.push(.privacyNotice)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
    }

    private var header: some View {
        Text("我的")
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(AppTheme.background.opacity(0.9))
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: 1)
            }
    }

    private func profileRow(icon: String, title: String, highlight: Bool = false, showsDivider: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(highlight ? AppTheme.primary : Color.gray.opacity(0.9))
                        .frame(width: 18, height: 18)
                    Text(title)
                        .font(.system(size: 15, weight: highlight ? .bold : .medium))
                        .foregroundStyle(highlight ? AppTheme.primary : .white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.gray.opacity(0.7))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(Color.clear)

                if showsDivider {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct HelpFeedbackView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            AppPageHeader(
                title: "帮助与反馈",
                leadingSystemImage: "chevron.left",
                onLeadingTap: { router.pop() }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    AppCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(AppTheme.primary)
                                Text("使用帮助")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            helpLine(title: "拍摄失败怎么办？", detail: "优先检查机位是否固定、动作主体是否完整入镜，以及光线是否足够。")
                            helpLine(title: "分析结果不理想怎么办？", detail: "重新拍摄时尽量贴近动作主体，并确保杠铃、身体关键关节和完整动作过程都能看到。")
                            helpLine(title: "订阅后没生效怎么办？", detail: "可先尝试重新打开应用，若仍异常，可通过下方反馈方式联系我们。")
                        }
                    }

                    AppCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .foregroundStyle(AppTheme.primary)
                                Text("反馈方式")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            Text("如果你遇到崩溃、识别异常、订阅问题或希望补充新动作库，可以把问题描述、设备型号和录屏整理后发送给我们。")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.textSecondary)

                            feedbackBadge(title: "反馈邮箱", value: "support@wintrain.app")
                            feedbackBadge(title: "建议附带信息", value: "问题描述 / 设备型号 / 录屏")
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
    }

    private func helpLine(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            Text(detail)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func feedbackBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.primary)
                .textCase(.uppercase)
                .tracking(1.2)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.cardMuted)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct PrivacyNoticeView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            AppPageHeader(
                title: "隐私说明",
                leadingSystemImage: "chevron.left",
                onLeadingTap: { router.pop() }
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    AppCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 14) {
                            privacySection(
                                title: "我们收集什么",
                                detail: "当前版本主要处理你主动上传的视频、分析结果，以及订阅状态相关的本地权益信息。"
                            )
                            privacySection(
                                title: "我们如何使用",
                                detail: "这些数据仅用于动作分析、结果展示、历史记录保存和权益判断，不会用于与训练无关的用途。"
                            )
                            privacySection(
                                title: "本地存储说明",
                                detail: "历史记录和部分视频片段会保存在本机，便于你回看和复盘；你可以在记录页中删除对应内容。"
                            )
                        }
                    }

                    AppCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield")
                                    .foregroundStyle(AppTheme.primary)
                                Text("隐私承诺")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            AppBulletText("仅在分析所需范围内处理你主动选择的视频")
                            AppBulletText("你可以通过删除记录清除本地保存的分析内容")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
    }

    private func privacySection(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            Text(detail)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
