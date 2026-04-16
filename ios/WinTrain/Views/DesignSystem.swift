import SwiftUI

enum AppTheme {
    static let background = Color(hex: "#0A1214")
    static let card = Color(hex: "#142024")
    static let cardMuted = Color(hex: "#101A1D")
    static let border = Color(hex: "#1E2C31")
    static let primary = Color(hex: "#11A4D4")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#8A9496")
    static let success = Color(hex: "#10B748")
    static let warning = Color(hex: "#F59E0B")
    static let danger = Color(hex: "#EF4444")
}

struct AppSurfaceBackground: View {
    var body: some View {
        AppTheme.background.ignoresSafeArea()
    }
}

struct AppCard<Content: View>: View {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let content: Content

    init(padding: CGFloat = 20, cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct AppPrimaryButton: View {
    let title: String
    let icon: String?
    var isDisabled = false
    var cornerRadius: CGFloat = 16
    var foreground: Color = .white
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 18, weight: .heavy))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(isDisabled ? AppTheme.textSecondary : foreground)
            .background(isDisabled ? AppTheme.primary.opacity(0.2) : AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: AppTheme.primary.opacity(isDisabled ? 0 : 0.24), radius: 20, y: 8)
        }
        .disabled(isDisabled)
    }
}

struct AppSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(AppTheme.textPrimary)
            .background(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct AppIconButton: View {
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 40, height: 40)
                .foregroundStyle(tint)
                .background(Color.white.opacity(0.04))
                .clipShape(Circle())
        }
    }
}

struct AppPageHeader: View {
    let title: String
    var leadingSystemImage: String? = nil
    var trailingSystemImage: String? = nil
    var onLeadingTap: (() -> Void)? = nil
    var onTrailingTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let leadingSystemImage, let onLeadingTap {
                AppIconButton(systemImage: leadingSystemImage, tint: .white, action: onLeadingTap)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }

            Text(title)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)

            if let trailingSystemImage, let onTrailingTap {
                AppIconButton(systemImage: trailingSystemImage, tint: .white, action: onTrailingTap)
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(AppTheme.background.opacity(0.9))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
    }
}

struct StatusChipStyle {
    let foreground: Color
    let background: Color
    let border: Color
}

struct AppStatusChip: View {
    let title: String
    let style: StatusChipStyle

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy))
            .tracking(0.8)
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(style.background)
            .overlay(
                Capsule()
                    .stroke(style.border, lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}

struct AppBottomNavigationBar: View {
    let selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
            HStack {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: tab.systemImage)
                                .font(.system(size: 24, weight: selectedTab == tab ? .bold : .regular))
                                .symbolVariant(selectedTab == tab ? .fill : .none)
                                .frame(height: 24)
                            Text(tab.title)
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.6)
                                .textCase(.uppercase)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundStyle(selectedTab == tab ? AppTheme.primary : AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 44, alignment: .top)
                        .padding(.top, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 4)
        }
        .background(AppTheme.background.opacity(0.95))
    }
}

struct AppBrandLockup: View {
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    var subtitlePill = false

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("稳练")
                .font(.system(size: titleSize, weight: .black))
                .foregroundStyle(.white)

            Text("WINTRAIN")
                .font(.system(size: subtitleSize, weight: .regular))
                .foregroundStyle(AppTheme.textSecondary)
                .tracking(1.8)
                .padding(.horizontal, subtitlePill ? 6 : 0)
                .padding(.vertical, subtitlePill ? 2 : 0)
                .background(
                    subtitlePill ? Color.white.opacity(0.05) : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .fixedSize(horizontal: true, vertical: true)
        }
    }
}

struct AppLogoGlyph: View {
    var tint: Color = AppTheme.primary
    var barHeight: CGFloat = 54
    var fontSize: CGFloat = 40
    var weight: Font.Weight = .black

    var body: some View {
        HStack(spacing: 2) {
            logoBarbellSide(mirrored: false)
            Text("W")
                .font(.system(size: fontSize, weight: weight))
                .foregroundStyle(tint)
                .offset(y: -1)
            logoBarbellSide(mirrored: true)
        }
        .fixedSize()
    }

    private func logoBarbellSide(mirrored: Bool) -> some View {
        HStack(spacing: 2) {
            Group {
                Capsule().frame(width: 6, height: barHeight * 0.42)
                Capsule().frame(width: 8, height: barHeight * 0.62)
                Capsule().frame(width: 10, height: barHeight)
                Rectangle().frame(width: 8, height: 3)
            }
            .foregroundStyle(tint)
        }
        .scaleEffect(x: mirrored ? -1 : 1, y: 1)
    }
}

struct AppRemoteImage: View {
    let assetName: String?
    let urlString: String?
    let contentMode: ContentMode

    init(assetName: String? = nil, urlString: String? = nil, contentMode: ContentMode = .fill) {
        self.assetName = assetName
        self.urlString = urlString
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let assetName {
                Image(assetName)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                AsyncImage(url: URL(string: urlString ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: contentMode)
                    default:
                        LinearGradient(
                            colors: [AppTheme.card, AppTheme.cardMuted],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .overlay {
                            Image(systemName: "sparkles.tv")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundStyle(AppTheme.primary.opacity(0.7))
                        }
                    }
                }
            }
        }
    }
}

struct AppMetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)
            Text(value)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct AppSectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .heavy))
            .foregroundStyle(AppTheme.textSecondary)
            .tracking(2.4)
    }
}

struct AppBulletText: View {
    let text: String
    let color: Color
    let size: CGFloat

    init(_ text: String, color: Color = AppTheme.textSecondary, size: CGFloat = 4) {
        self.text = text
        self.color = color
        self.size = size
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(color.opacity(0.7))
                .frame(width: size, height: size)
                .padding(.top, 7)
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(color)
        }
    }
}

extension Color {
    init(hex: String) {
        let hexString = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexString)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

func resultStatusStyle(for result: AnalysisResult?) -> StatusChipStyle {
    guard let result else {
        return StatusChipStyle(
            foreground: AppTheme.danger,
            background: AppTheme.danger.opacity(0.12),
            border: AppTheme.danger.opacity(0.3)
        )
    }

    if result.status == "low_confidence" {
        return StatusChipStyle(
            foreground: AppTheme.warning,
            background: AppTheme.warning.opacity(0.12),
            border: AppTheme.warning.opacity(0.3)
        )
    }

    let hasMajorFeedback = result.feedbacks.contains { $0.severity != "info" }
    if hasMajorFeedback {
        return StatusChipStyle(
            foreground: AppTheme.warning,
            background: AppTheme.warning.opacity(0.12),
            border: AppTheme.warning.opacity(0.3)
        )
    }

    return StatusChipStyle(
        foreground: AppTheme.success,
        background: AppTheme.success.opacity(0.12),
        border: AppTheme.success.opacity(0.3)
    )
}

func resultStatusTitle(for result: AnalysisResult) -> String {
    if result.status == "low_confidence" {
        return "低置信度"
    }
    let hasMajorFeedback = result.feedbacks.contains { $0.severity != "info" }
    return hasMajorFeedback ? "需改进" : "优秀"
}
