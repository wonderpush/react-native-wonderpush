require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-wonderpush"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-wonderpush
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-wonderpush"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-wonderpush.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true

  s.dependency 'React',  '>= 0.13.0', '< 1.0.0'
  s.dependency 'WonderPush', '4.3.2'
end
