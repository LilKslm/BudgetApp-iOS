platform :ios, '17.0'
use_frameworks! :linkage => :static
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

    # Fix "Create Symlinks to Header Folders" script phases — Xcode 16 fails
    # builds when a script phase has no declared outputs and isn't marked
    # always-out-of-date.
    target.build_phases.each do |phase|
      next unless phase.respond_to?(:name) && phase.name == 'Create Symlinks to Header Folders'
      phase.always_out_of_date = '1'
    end

    # -GCC_WARN_INHIBIT_ALL_WARNINGS is parsed by clang as -G (unsupported on iOS simulator)
    next unless target.name == 'BoringSSL-GRPC'
    target.source_build_phase.files.each do |file|
      next unless file.settings && file.settings['COMPILER_FLAGS']
      file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS']
        .split(' ')
        .reject { |f| f.start_with?('-G') }
        .join(' ')
    end
  end
end
