require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-wonderpush"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/wonderpush/react-native-wonderpush.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,cpp}"
  s.private_header_files = "ios/**/*.h"

  # The WonderPush iOS SDK is distributed through Swift Package Manager (v4.5.1+).
  # CocoaPods stays on v4.4.3, the last version published there, and is only used as a fallback
  # when React Native's `spm_dependency` helper is unavailable (React Native < 0.75).
  if respond_to?(:spm_dependency, true)
    spm_dependency(s,
      url: 'https://github.com/wonderpush/wonderpush-ios-sdk.git',
      requirement: { kind: 'exactVersion', version: '4.5.2' },
      products: ['WonderPush']
    )
  else
    s.dependency 'WonderPush', '4.4.3'
  end

  install_modules_dependencies(s)
end
