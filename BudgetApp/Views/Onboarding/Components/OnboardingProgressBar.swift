import SwiftUI

struct OnboardingProgressBar: View {
    let progress: Double   // 0.0 – 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.Colors.divider)
                    .frame(height: 4)

                Capsule()
                    .fill(AppTheme.Gradients.primary)
                    .frame(width: geo.size.width * max(0, min(1, progress)), height: 4)
                    .animation(AppTheme.Motion.standard, value: progress)
            }
        }
        .frame(height: 4)
    }
}
