#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint liquid_flutter_window_utils.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'liquid_flutter_window_utils'
  s.version          = '0.0.1'
  s.summary          = 'Utility platform interface for interacting with the window'
  s.description      = <<-DESC
Utility platform interface for interacting with the window
                       DESC
  s.homepage         = 'https://github.com/emdgroup-liquid/liquid-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'EMD Group Liquid' => 'email@example.com' }

  s.source           = { :path => '.' }
  s.source_files = 'liquid_flutter_window_utils/Sources/liquid_flutter_window_utils/**/*.swift'
  s.resource_bundles = {'liquid_flutter_window_utils_privacy' => ['liquid_flutter_window_utils/Sources/liquid_flutter_window_utils/Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '13.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
