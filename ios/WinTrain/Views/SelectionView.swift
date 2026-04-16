import SwiftUI

struct SelectionView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 0) {
            AppPageHeader(
                title: "选择动作",
                leadingSystemImage: "chevron.left",
                onLeadingTap: { router.selectTab(.home) },
                onTrailingTap: nil
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Exercise.supported) { exercise in
                        Button {
                            router.push(.guide(exerciseID: exercise.id))
                        } label: {
                            HStack(spacing: 16) {
                                AppRemoteImage(assetName: exercise.imageAssetName)
                                    .frame(width: 80, height: 80)
                                    .background(Color.black.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exercise.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)

                                    VStack(alignment: .leading, spacing: 4) {
                                        selectionLine(text: "目标：\(exercise.targets)")
                                        selectionLine(text: "建议视角：\(exercise.view)")
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.white.opacity(0.3))
                            }
                            .padding(16)
                            .background(AppTheme.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppSurfaceBackground())
    }

    private func selectionLine(text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(AppTheme.primary.opacity(0.6))
                .frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}
