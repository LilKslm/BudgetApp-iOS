import Foundation

enum NotificationPermissionStatus {
    case notDetermined, granted, denied
}

protocol NotificationServiceProtocol: AnyObject, Sendable {
    func requestPermission() async -> Bool
    func currentStatus() async -> NotificationPermissionStatus
}

final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    private(set) var requestedPermission = false

    func requestPermission() async -> Bool {
        try? await Task.sleep(nanoseconds: 500_000_000)
        requestedPermission = true
        AppLogger.info("MockNotificationService: permission granted")
        return true
    }

    func currentStatus() async -> NotificationPermissionStatus {
        return requestedPermission ? .granted : .notDetermined
    }
}
