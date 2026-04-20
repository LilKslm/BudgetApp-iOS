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
      if phase.respond_to?(:name) && phase.name == 'Create Symlinks to Header Folders'
        phase.always_out_of_date = '1'
      end
    end

    # Xcode 16 clang treats -Wmissing-template-arg-list-after-template-kw as
    # an error in gRPC source (affects gRPC-Core, gRPC-C++, etc). Suppress it.
    if target.name.start_with?('gRPC')
      target.build_configurations.each do |config|
        config.build_settings['OTHER_CPLUSPLUSFLAGS'] = '$(inherited) -Wno-missing-template-arg-list-after-template-kw'
      end
    end

    # BoringSSL-GRPC: inhibit_all_warnings! + :linkage => :static causes CocoaPods
    # to inject -GCC_WARN_INHIBIT_ALL_WARNINGS into per-file COMPILER_FLAGS.
    # Clang parses -G<word> as the unsupported -G option on iOS simulator, so
    # strip it from every source file's compiler flags. (BoringSSL-GRPC does NOT
    # start with 'gRPC', so this must be a parallel if block, not chained after
    # the gRPC guard above.)
    if target.name == 'BoringSSL-GRPC'
      target.source_build_phase.files.each do |file|
        next unless file.settings && file.settings['COMPILER_FLAGS']
        file.settings['COMPILER_FLAGS'] = file.settings['COMPILER_FLAGS']
          .gsub(/-GCC_WARN_INHIBIT_ALL_WARNINGS/, '')
          .squeeze(' ').strip
      end
    end
  end
end
