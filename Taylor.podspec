#
# Be sure to run `pod lib lint Taylor.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Taylor"
  s.version          = "0.3.2"
  s.summary          = "HTTP server written in Swift."
  s.description      = <<-DESC
                       A HTTP server written in Swift
DESC
  s.homepage         = "https://github.com/izqui/Taylor"

  s.license          = 'MIT'
  s.author           = { "Jorge Izquierdo" => "jorge@izqui.me" }
  s.source           = { :git => "https://github.com/izqui/Taylor.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/izqui9'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  
  s.requires_arc = true

  s.source_files = 'Sources/Taylor/*.swift'

  s.dependency 'SwiftSockets', '~> 0.20.2'
end
