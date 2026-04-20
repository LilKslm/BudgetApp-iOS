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
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64' if target.name.start_with?('Pods')
    end

    # BoringSSL-GRPC ships with an unsupported '-G' compiler flag on Xcode 16+
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        if file.settings && file.settings['COMPILER_FLAGS']
          file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS']
            .split
            .reject { |f| f == '-G' }
            .join(' ')
        end
      end
    end
  end
end
