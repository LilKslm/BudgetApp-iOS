import SwiftUI

struct MoneyBillProgressView: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            let clampedProgress = max(0, min(1, progress))
            let fillWidth = geo.size.width * clampedProgress

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.Colors.surfaceMuted)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(AppTheme.Colors.divider, lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: max(24, fillWidth))
                    .animation(AppTheme.Motion.standard, value: progress)

                Text("$")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(.white)
                    .offset(x: max(6, fillWidth - 14))
                    .animation(AppTheme.Motion.standard, value: progress)
            }
        }
        .frame(height: 22)
    }
}
