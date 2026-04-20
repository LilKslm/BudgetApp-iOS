platform :ios, '17.0'
use_frameworks!
inhibit_all_warnings!

target 'BudgetApp' do
  # Firebase
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  pod 'FirebaseAnalytics'
  pod 'FirebaseCrashlytics'

  # Google Sign-In
  pod 'GoogleSignIn'

  # Payments
  pod 'RevenueCat'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end

    # BoringSSL-GRPC ships with an unsupported '-G' compiler flag on Xcode 16+
    next unless target.name == 'BoringSSL-GRPC'
    target.source_build_phase.files.each do |file|
      next unless file.settings && file.settings['COMPILER_FLAGS']
      file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS']
        .split
        .reject { |f| f == '-G' }
        .join(' ')
    end
  end
end
