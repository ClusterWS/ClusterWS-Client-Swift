Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Client-Swift'
  s.version          = '2.0.2'
  s.summary          = 'Native iOS client for ClusterWS'
 
  s.description      = 'Native iOS client for ClusterWS. Simple and easy to use sockets & socket stream library with channel communication and asynchronous calls.'
 
  s.homepage         = 'https://github.com/ClusterWS/ClusterWS-Client-Swift'
  s.license          = { :type => 'MIT' }

  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/ClusterWS/ClusterWS-Client-Swift.git', :tag => s.version.to_s }
 
  s.requires_arc = true

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.source_files = 'Core'
  s.libraries = 'z'

  #s.dependency "SwiftWebSocket"
 
end