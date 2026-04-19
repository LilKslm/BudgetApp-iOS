import UIKit

protocol HapticServiceProtocol {
    func success()
    func warning()
    func error()
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle)
    func selection()
}

/// All haptic feedback in the app flows through this service — per appcreation.md §5,
/// views never instantiate UIFeedbackGenerator directly.
final class HapticService: HapticServiceProtocol {
    func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
