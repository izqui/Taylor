Pod::Spec.new do |s|
  s.name = 'Taylor'
  s.version = '0.1.0'
  s.license = 'MIT'
  s.summary = 'HTTP server written in Swift'
  s.homepage = 'https://github.com/izqui9'
  s.social_media_url = 'http://twitter.com/izqui9'
  s.authors = { 'Jorge Izquierdo' => 'jorge@izqui.me' }
  s.source = { :git => 'https://github.com/izqui/Taylor.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'taylor/Taylor/*.swift'

  s.requires_arc = true

end