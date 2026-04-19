# iOS App Infrastructure — Master Reference

> Production-grade iOS app blueprint. Every new project starts here. No shortcuts.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Swift / SwiftUI |
| Backend | Firebase (Auth, Firestore, Analytics, Crashlytics) |
| Payments | RevenueCat |
| Architecture | MVVM + Clean Architecture |
| Concurrency | async/await throughout |
| Testing | XCTest + protocol-based DI |

---

## Project Folder Structure

```
MyApp/
├── App/
│   ├── MyAppApp.swift          # @main entry point
│   ├── AppDelegate.swift       # UIApplicationDelegate (Firebase init)
│   └── ContentView.swift       # Root router view
│
├── Core/
│   ├── DI/
│   │   └── AppContainer.swift  # Dependency injection container
│   ├── Errors/
│   │   └── AppError.swift      # Unified error types
│   ├── Logging/
│   │   └── Logger.swift        # Centralized logger
│   └── Extensions/
│       ├── View+Extensions.swift
│       ├── String+Extensions.swift
│       └── Date+Extensions.swift
│
├── Models/
│   ├── User.swift
│   ├── Subscription.swift
│   └── [FeatureModel].swift
│
├── Services/
│   ├── AuthService.swift
│   ├── DataService.swift
│   ├── AnalyticsService.swift
│   ├── PaymentService.swift
│   └── NotificationService.swift
│
├── ViewModels/
│   ├── AppViewModel.swift
│   ├── AuthViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── PaywallViewModel.swift
│   └── [Feature]ViewModel.swift
│
├── Views/
│   ├── Onboarding/
│   │   ├── OnboardingView.swift
│   │   └── OnboardingPageView.swift
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   └── SignUpView.swift
│   ├── Paywall/
│   │   └── PaywallView.swift
│   ├── Main/
│   │   └── MainTabView.swift
│   └── Components/
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── PrimaryButton.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── GoogleService-Info.plist
│
└── Tests/
    ├── Unit/
    │   ├── AuthServiceTests.swift
    │   └── [Feature]ViewModelTests.swift
    └── Mocks/
        ├── MockAuthService.swift
        └── MockDataService.swift
```

---

## Package Dependencies (Swift Package Manager)

Add via Xcode → File → Add Package Dependencies:

```
Firebase iOS SDK
  https://github.com/firebase/firebase-ios-sdk
  Products: FirebaseAuth, FirebaseFirestore, FirebaseAnalytics, FirebaseCrashlytics

RevenueCat
  https://github.com/RevenueCat/purchases-ios
  Product: RevenueCat
```

---

## Error Handling

```swift
// Core/Errors/AppError.swift

enum AppError: LocalizedError {
    // Auth
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword

    // Network / Data
    case networkUnavailable
    case decodingFailed(String)
    case documentNotFound
    case permissionDenied

    // Payments
    case purchaseFailed(String)
    case restoreFailed
    case productNotFound

    // Generic
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:   return "Invalid email or password."
        case .userNotFound:         return "No account found with that email."
        case .emailAlreadyInUse:    return "An account already exists for this email."
        case .weakPassword:         return "Password must be at least 8 characters."
        case .networkUnavailable:   return "No internet connection. Please try again."
        case .decodingFailed(let msg): return "Data error: \(msg)"
        case .documentNotFound:     return "Requested data not found."
        case .permissionDenied:     return "You don't have permission to do that."
        case .purchaseFailed(let msg): return "Purchase failed: \(msg)"
        case .restoreFailed:        return "Could not restore purchases."
        case .productNotFound:      return "Subscription product unavailable."
        case .unknown(let e):       return e.localizedDescription
        }
    }
}
```

---

## Logger

```swift
// Core/Logging/Logger.swift

import Foundation
import FirebaseCrashlytics

enum LogLevel: String {
    case debug = "DEBUG"
    case info  = "INFO"
    case warn  = "WARN"
    case error = "ERROR"
}

struct AppLogger {
    static func log(_ level: LogLevel, _ message: String, file: String = #file, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let entry = "[\(level.rawValue)] [\(fileName):\(line)] \(message)"

        #if DEBUG
        print(entry)
        #endif

        if level == .error {
            Crashlytics.crashlytics().log(entry)
        }
    }

    static func debug(_ msg: String, file: String = #file, line: Int = #line) { log(.debug, msg, file: file, line: line) }
    static func info(_ msg: String,  file: String = #file, line: Int = #line) { log(.info,  msg, file: file, line: line) }
    static func warn(_ msg: String,  file: String = #file, line: Int = #line) { log(.warn,  msg, file: file, line: line) }
    static func error(_ msg: String, file: String = #file, line: Int = #line) { log(.error, msg, file: file, line: line) }
}
```

---

## App Entry Point

```swift
// App/MyAppApp.swift

import SwiftUI
import Firebase

@main
struct MyAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appViewModel)
        }
    }
}

// App/AppDelegate.swift

import UIKit
import Firebase
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        AppLogger.info("App launched")
        return true
    }
}
```

---

## Services

### AuthService

```swift
// Services/AuthService.swift

import Foundation
import FirebaseAuth
import GoogleSignIn

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signInWithGoogle() async throws -> User
    func signOut() throws
    func deleteAccount() async throws
    func resetPassword(email: String) async throws
}

final class AuthService: AuthServiceProtocol, ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: User?
    @Published var isAuthenticated = false

    private var authStateListener: AuthStateDidChangeListenerHandle?

    private init() {
        setupAuthListener()
    }

    private func setupAuthListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                AppLogger.info("Auth state changed: \(user?.uid ?? "nil")")
            }
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            AnalyticsService.shared.track(.login(method: "email"))
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            AnalyticsService.shared.track(.signUp(method: "email"))
            return result.user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }

    func signInWithGoogle() async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AppError.unknown(NSError(domain: "Auth", code: -1))
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = await windowScene.windows.first?.rootViewController else {
            throw AppError.unknown(NSError(domain: "Auth", code: -2))
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AppError.unknown(NSError(domain: "Auth", code: -3))
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        AnalyticsService.shared.track(.login(method: "google"))
        return authResult.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
        AnalyticsService.shared.track(.logout)
    }

    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    private func mapAuthError(_ error: NSError) -> AppError {
        switch AuthErrorCode(rawValue: error.code) {
        case .wrongPassword, .invalidEmail:    return .invalidCredentials
        case .userNotFound:                    return .userNotFound
        case .emailAlreadyInUse:               return .emailAlreadyInUse
        case .weakPassword:                    return .weakPassword
        default:                               return .unknown(error)
        }
    }
}
```

### DataService

```swift
// Services/DataService.swift

import Foundation
import FirebaseFirestore

protocol DataServiceProtocol {
    func fetch<T: Decodable>(collection: String, documentId: String) async throws -> T
    func save<T: Encodable>(_ object: T, collection: String, documentId: String) async throws
    func update(collection: String, documentId: String, fields: [String: Any]) async throws
    func delete(collection: String, documentId: String) async throws
    func listen<T: Decodable>(collection: String, documentId: String, onChange: @escaping (Result<T, AppError>) -> Void) -> ListenerRegistration
}

final class DataService: DataServiceProtocol {
    static let shared = DataService()

    private let db = Firestore.firestore()

    private init() {}

    func fetch<T: Decodable>(collection: String, documentId: String) async throws -> T {
        let snapshot = try await db.collection(collection).document(documentId).getDocument()
        guard snapshot.exists else { throw AppError.documentNotFound }
        return try snapshot.data(as: T.self)
    }

    func save<T: Encodable>(_ object: T, collection: String, documentId: String) async throws {
        try db.collection(collection).document(documentId).setData(from: object)
    }

    func update(collection: String, documentId: String, fields: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).updateData(fields)
    }

    func delete(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }

    func listen<T: Decodable>(collection: String, documentId: String, onChange: @escaping (Result<T, AppError>) -> Void) -> ListenerRegistration {
        return db.collection(collection).document(documentId).addSnapshotListener { snapshot, error in
            if let error {
                onChange(.failure(.unknown(error)))
                return
            }
            guard let snapshot, snapshot.exists else {
                onChange(.failure(.documentNotFound))
                return
            }
            do {
                let value = try snapshot.data(as: T.self)
                onChange(.success(value))
            } catch {
                onChange(.failure(.decodingFailed(error.localizedDescription)))
            }
        }
    }
}
```

### AnalyticsService

```swift
// Services/AnalyticsService.swift

import Foundation
import FirebaseAnalytics

enum AnalyticsEvent {
    // Auth
    case login(method: String)
    case signUp(method: String)
    case logout

    // Onboarding
    case onboardingStarted
    case onboardingStepCompleted(step: Int)
    case onboardingCompleted

    // Paywall
    case paywallShown(trigger: String)
    case paywallDismissed
    case paywallPurchaseTapped(productId: String)
    case paywallPurchaseCompleted(productId: String)
    case paywallRestored

    // Feature
    case featureUsed(name: String)
    case screenViewed(name: String)

    // Subscription
    case subscriptionStarted(productId: String)
    case subscriptionCancelled
    case subscriptionExpired

    var name: String {
        switch self {
        case .login:                    return "login"
        case .signUp:                   return "sign_up"
        case .logout:                   return "logout"
        case .onboardingStarted:        return "onboarding_started"
        case .onboardingStepCompleted:  return "onboarding_step_completed"
        case .onboardingCompleted:      return "onboarding_completed"
        case .paywallShown:             return "paywall_shown"
        case .paywallDismissed:         return "paywall_dismissed"
        case .paywallPurchaseTapped:    return "paywall_purchase_tapped"
        case .paywallPurchaseCompleted: return "paywall_purchase_completed"
        case .paywallRestored:          return "paywall_restored"
        case .featureUsed:              return "feature_used"
        case .screenViewed:             return "screen_viewed"
        case .subscriptionStarted:      return "subscription_started"
        case .subscriptionCancelled:    return "subscription_cancelled"
        case .subscriptionExpired:      return "subscription_expired"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .login(let method):                        return ["method": method]
        case .signUp(let method):                       return ["method": method]
        case .onboardingStepCompleted(let step):        return ["step": step]
        case .paywallShown(let trigger):                return ["trigger": trigger]
        case .paywallPurchaseTapped(let id):            return ["product_id": id]
        case .paywallPurchaseCompleted(let id):         return ["product_id": id]
        case .featureUsed(let name):                    return ["feature_name": name]
        case .screenViewed(let name):                   return ["screen_name": name]
        case .subscriptionStarted(let id):              return ["product_id": id]
        default:                                        return nil
        }
    }
}

final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func track(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
        AppLogger.debug("Analytics: \(event.name) \(event.parameters ?? [:])")
    }

    func setUserProperty(_ value: String?, for name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    func setUserId(_ id: String?) {
        Analytics.setUserID(id)
    }
}
```

### PaymentService (RevenueCat)

```swift
// Services/PaymentService.swift

import Foundation
import RevenueCat

protocol PaymentServiceProtocol {
    var isPremium: Bool { get }
    func configure(apiKey: String)
    func fetchOfferings() async throws -> Offerings
    func purchase(package: Package) async throws -> CustomerInfo
    func restorePurchases() async throws -> CustomerInfo
    func getCustomerInfo() async throws -> CustomerInfo
}

final class PaymentService: PaymentServiceProtocol, ObservableObject {
    static let shared = PaymentService()

    @Published var isPremium = false
    @Published var customerInfo: CustomerInfo?

    private init() {}

    func configure(apiKey: String) {
        Purchases.configure(withAPIKey: apiKey)
        Purchases.logLevel = .warn

        Task {
            await refreshCustomerInfo()
        }
    }

    func fetchOfferings() async throws -> Offerings {
        return try await Purchases.shared.offerings()
    }

    func purchase(package: Package) async throws -> CustomerInfo {
        let result = try await Purchases.shared.purchase(package: package)
        await MainActor.run {
            self.customerInfo = result.customerInfo
            self.isPremium = result.customerInfo.entitlements.active["premium"] != nil
        }
        AnalyticsService.shared.track(.paywallPurchaseCompleted(productId: package.storeProduct.productIdentifier))
        return result.customerInfo
    }

    func restorePurchases() async throws -> CustomerInfo {
        let info = try await Purchases.shared.restorePurchases()
        await MainActor.run {
            self.customerInfo = info
            self.isPremium = info.entitlements.active["premium"] != nil
        }
        AnalyticsService.shared.track(.paywallRestored)
        return info
    }

    func getCustomerInfo() async throws -> CustomerInfo {
        let info = try await Purchases.shared.customerInfo()
        await MainActor.run {
            self.customerInfo = info
            self.isPremium = info.entitlements.active["premium"] != nil
        }
        return info
    }

    private func refreshCustomerInfo() async {
        do {
            _ = try await getCustomerInfo()
        } catch {
            AppLogger.warn("Failed to refresh customer info: \(error.localizedDescription)")
        }
    }
}
```

---

## ViewModels

### AppViewModel (Root State)

```swift
// ViewModels/AppViewModel.swift

import SwiftUI
import Combine

enum AppState {
    case loading
    case onboarding
    case paywall
    case authenticated
    case unauthenticated
}

final class AppViewModel: ObservableObject {
    @Published var state: AppState = .loading
    @Published var error: AppError?
    @Published var isShowingError = false

    private let auth = AuthService.shared
    private let payments = PaymentService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        auth.$isAuthenticated
            .combineLatest(payments.$isPremium)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth, isPremium in
                self?.updateState(isAuthenticated: isAuth, isPremium: isPremium)
            }
            .store(in: &cancellables)
    }

    private func updateState(isAuthenticated: Bool, isPremium: Bool) {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

        if !hasSeenOnboarding {
            state = .onboarding
        } else if !isAuthenticated {
            state = .unauthenticated
        } else if !isPremium {
            state = .paywall
        } else {
            state = .authenticated
        }
    }

    func showError(_ error: AppError) {
        self.error = error
        self.isShowingError = true
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        AnalyticsService.shared.track(.onboardingCompleted)
        updateState(isAuthenticated: auth.isAuthenticated, isPremium: payments.isPremium)
    }
}
```

### AuthViewModel

```swift
// ViewModels/AuthViewModel.swift

import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: AppError?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol = AuthService.shared) {
        self.authService = authService
    }

    @MainActor
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            error = .invalidCredentials
            return
        }
        isLoading = true
        error = nil
        do {
            _ = try await authService.signIn(email: email, password: password)
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error)
        }
        isLoading = false
    }

    @MainActor
    func signUp() async {
        isLoading = true
        error = nil
        do {
            _ = try await authService.signUp(email: email, password: password)
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error)
        }
        isLoading = false
    }

    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        error = nil
        do {
            _ = try await authService.signInWithGoogle()
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .unknown(error)
        }
        isLoading = false
    }
}
```

### PaywallViewModel

```swift
// ViewModels/PaywallViewModel.swift

import SwiftUI
import RevenueCat

final class PaywallViewModel: ObservableObject {
    @Published var offerings: Offerings?
    @Published var isLoading = false
    @Published var isPurchasing = false
    @Published var error: AppError?
    @Published var didPurchase = false

    private let payments: PaymentServiceProtocol

    init(payments: PaymentServiceProtocol = PaymentService.shared) {
        self.payments = payments
    }

    @MainActor
    func loadOfferings() async {
        isLoading = true
        do {
            offerings = try await payments.fetchOfferings()
        } catch {
            self.error = .unknown(error)
        }
        isLoading = false
    }

    @MainActor
    func purchase(_ package: Package) async {
        isPurchasing = true
        error = nil
        AnalyticsService.shared.track(.paywallPurchaseTapped(productId: package.storeProduct.productIdentifier))
        do {
            _ = try await payments.purchase(package: package)
            didPurchase = true
        } catch let e as AppError {
            error = e
        } catch {
            self.error = .purchaseFailed(error.localizedDescription)
        }
        isPurchasing = false
    }

    @MainActor
    func restore() async {
        isPurchasing = true
        error = nil
        do {
            _ = try await payments.restorePurchases()
            didPurchase = true
        } catch {
            self.error = .restoreFailed
        }
        isPurchasing = false
    }
}
```

---

## Views

### ContentView (Root Router)

```swift
// App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        Group {
            switch appViewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .onboarding:
                OnboardingView()

            case .unauthenticated:
                LoginView()

            case .paywall:
                PaywallView()
                    .onAppear {
                        AnalyticsService.shared.track(.paywallShown(trigger: "auth"))
                    }

            case .authenticated:
                MainTabView()
            }
        }
        .alert("Something went wrong", isPresented: $appViewModel.isShowingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appViewModel.error?.localizedDescription ?? "Unknown error")
        }
    }
}
```

### PaywallView

```swift
// Views/Paywall/PaywallView.swift

import SwiftUI
import RevenueCat

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Unlock Premium")
                    .font(.largeTitle.bold())
                Text("Get full access to all features")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 48)

            Spacer()

            // Packages
            if viewModel.isLoading {
                ProgressView()
            } else if let offering = viewModel.offerings?.current {
                VStack(spacing: 12) {
                    ForEach(offering.availablePackages, id: \.identifier) { package in
                        PackageRow(package: package) {
                            Task { await viewModel.purchase(package) }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Restore
            Button("Restore Purchases") {
                Task { await viewModel.restore() }
            }
            .foregroundStyle(.secondary)
            .font(.footnote)
            .padding(.bottom, 32)
        }
        .overlay {
            if viewModel.isPurchasing {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
        .task { await viewModel.loadOfferings() }
        .onChange(of: viewModel.didPurchase) { _, purchased in
            if purchased { appViewModel.completeOnboarding() }
        }
        .alert("Purchase Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}
```

### Reusable Components

```swift
// Views/Components/PrimaryButton.swift

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.accentColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isLoading)
    }
}
```

---

## Dependency Injection Container

```swift
// Core/DI/AppContainer.swift

final class AppContainer {
    static let shared = AppContainer()

    let authService: AuthServiceProtocol
    let dataService: DataServiceProtocol
    let analyticsService = AnalyticsService.shared
    let paymentService: PaymentServiceProtocol

    private init() {
        self.authService   = AuthService.shared
        self.dataService   = DataService.shared
        self.paymentService = PaymentService.shared
    }
}

// Swap real services for mocks in tests:
// AppContainer(authService: MockAuthService(), ...)
```

---

## Models

```swift
// Models/User.swift

struct AppUser: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String?
    var isPremium: Bool
    var createdAt: Date
    var onboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case isPremium   = "is_premium"
        case createdAt   = "created_at"
        case onboardingCompleted = "onboarding_completed"
    }
}

// Models/Subscription.swift

struct SubscriptionStatus: Codable {
    let productId: String
    let expiresAt: Date?
    let isActive: Bool
    let isTrial: Bool
}
```

---

## Push Notifications

```swift
// Services/NotificationService.swift

import UserNotifications
import FirebaseMessaging

final class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()

    @Published var fcmToken: String?

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        if granted == true {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
        return granted ?? false
    }

    func handleFCMToken(_ token: String) {
        self.fcmToken = token
        AppLogger.info("FCM token: \(token)")
        // Save to Firestore under user doc if needed
    }
}
```

---

## Testing — Mock Services

```swift
// Tests/Mocks/MockAuthService.swift

import Foundation
@testable import MyApp

final class MockAuthService: AuthServiceProtocol {
    var currentUser: User? = nil
    var isAuthenticated = false
    var shouldThrow = false
    var errorToThrow: AppError = .invalidCredentials

    func signIn(email: String, password: String) async throws -> User {
        if shouldThrow { throw errorToThrow }
        isAuthenticated = true
        return createMockUser()
    }

    func signUp(email: String, password: String) async throws -> User {
        if shouldThrow { throw errorToThrow }
        isAuthenticated = true
        return createMockUser()
    }

    func signInWithGoogle() async throws -> User {
        if shouldThrow { throw errorToThrow }
        return createMockUser()
    }

    func signOut() throws {
        isAuthenticated = false
        currentUser = nil
    }

    func deleteAccount() async throws {}
    func resetPassword(email: String) async throws {}

    private func createMockUser() -> User { fatalError("Return a mock FirebaseAuth.User") }
}
```

---

## Info.plist Keys Required

```xml
<!-- Firebase / Google Sign-In -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>$(REVERSED_CLIENT_ID)</string>  <!-- from GoogleService-Info.plist -->
    </array>
  </dict>
</array>

<!-- Push Notifications -->
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>

<!-- Camera / Photo Library (if needed) -->
<key>NSCameraUsageDescription</key>
<string>Used to set your profile photo.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to set your profile photo.</string>
```

---

## Firebase Setup Checklist

- [ ] Create Firebase project at console.firebase.google.com
- [ ] Add iOS app with correct Bundle ID
- [ ] Download `GoogleService-Info.plist` → drag into Xcode project root (do **not** add to a subfolder)
- [ ] Enable Email/Password auth in Firebase Console → Authentication → Sign-in method
- [ ] Enable Google Sign-In and add OAuth client ID
- [ ] Create Firestore database (start in test mode, lock down rules before launch)
- [ ] Enable Analytics and Crashlytics in Firebase Console
- [ ] Add `REVERSED_CLIENT_ID` URL scheme to Info.plist

**Firestore Security Rules (production):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## RevenueCat Setup Checklist

- [ ] Create RevenueCat account and project at app.revenuecat.com
- [ ] Link App Store Connect app (requires API key with "App Manager" access)
- [ ] Create Products in App Store Connect first (subscription group, products, durations)
- [ ] Create Entitlement in RevenueCat: `premium`
- [ ] Attach all subscription products to the `premium` entitlement
- [ ] Create an Offering and add Packages (annual, monthly, weekly)
- [ ] Copy API key (public SDK key) → use in `PaymentService.configure(apiKey:)`
- [ ] Set up Webhooks to Firebase Cloud Functions for server-side receipt validation (optional but recommended)

**Configure at app launch:**
```swift
// In AppDelegate.application(_:didFinishLaunchingWithOptions:)
PaymentService.shared.configure(apiKey: "your_revenuecat_public_key")
```

---

## Monetization Flows

### Hard Paywall After Onboarding
```
Launch → Onboarding (3-5 screens) → PaywallView (required) → Main App
```
- `AppViewModel.state` drives this via `completeOnboarding()` only setting `.authenticated` if `isPremium == true`
- Back button disabled on PaywallView

### Free Trial
- Configure trial in App Store Connect on the subscription product
- RevenueCat surfaces it automatically on the Package
- Display `package.storeProduct.introductoryDiscount` to show trial copy

### Restore Purchases
- `PaymentService.restorePurchases()` — always surface this on the paywall, required by App Store Review Guidelines

---

## Analytics Events Reference

| Event | Trigger |
|-------|---------|
| `onboarding_started` | First launch, OnboardingView appears |
| `onboarding_step_completed` | User advances a step |
| `onboarding_completed` | Final step dismissed |
| `paywall_shown` | PaywallView `.onAppear` |
| `paywall_dismissed` | User backs out (if allowed) |
| `paywall_purchase_tapped` | Tap on a package CTA |
| `paywall_purchase_completed` | Successful purchase |
| `paywall_restored` | Restore tapped and succeeded |
| `login` | Successful sign-in |
| `sign_up` | New account created |
| `screen_viewed` | Each major view's `.onAppear` |
| `feature_used` | Key feature interactions |
| `subscription_started` | New sub via RevenueCat webhook |
| `subscription_expired` | Sub lapsed |

---

## Code Patterns & Rules

### async/await — always
```swift
// CORRECT
let user = try await authService.signIn(email: email, password: password)

// WRONG — callbacks are banned
authService.signIn(email: email, password: password) { result in ... }
```

### @MainActor for UI updates
```swift
@MainActor
func loadData() async {
    isLoading = true
    defer { isLoading = false }
    // ...
}
```

### weak self in closures (Combine / callbacks only)
```swift
auth.$isAuthenticated
    .sink { [weak self] value in
        self?.updateState(...)
    }
    .store(in: &cancellables)
```

### Loading state pattern
```swift
// Every async VM function:
isLoading = true
defer { isLoading = false }
do {
    // work
} catch {
    self.error = .unknown(error)
}
```

### Never force-unwrap in production code
```swift
// WRONG
let id = user!.uid

// CORRECT
guard let user else { throw AppError.userNotFound }
let id = user.uid
```

---

## Xcode Project Configuration

**Build Settings:**
- Minimum Deployment Target: iOS 17.0
- Swift Language Version: Swift 6
- Enable Strict Concurrency: Complete

**Signing & Capabilities:**
- [ ] Push Notifications capability
- [ ] Sign in with Apple capability (if using Apple login)
- [ ] Background Modes → Remote notifications

**Schemes:**
- `Debug` — points to Firebase Emulator or dev project
- `Release` — points to production Firebase project

---

## App Store Connect Preparation Checklist

- [ ] Bundle ID registered in Apple Developer Portal
- [ ] App created in App Store Connect
- [ ] Subscription group created
- [ ] Products created with correct pricing tiers
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) added
- [ ] Privacy policy URL ready
- [ ] Age rating survey completed
- [ ] Screenshots prepared (6.7", 6.1", iPad if universal)
- [ ] App Preview video (optional but improves conversion)
- [ ] TestFlight internal testing configured
- [ ] Export Compliance — answer correctly for Firebase

---

## Launch Sequence

```
1. AppDelegate → FirebaseApp.configure(), PaymentService.configure()
2. AppViewModel observes Auth + Payment state
3. ContentView routes based on AppState
4. Onboarding → PaywallView → MainTabView
5. All analytics tracking wired from day 1
6. Crashlytics live from first build
```

---

*Last updated: April 2026 — for every new iOS project, clone this structure and fill in the app-specific feature models and views.*
