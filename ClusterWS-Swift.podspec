Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Swift'
  s.version          = '0.1.0'
  s.summary          = 'Native iOS client for ClusterWS'
 
  s.description      = 'Native iOS client for ClusterWS. Simple and easy to use sockets & socket stream library with channel communication and asynchronous calls.'
 
  s.homepage         = 'https://github.com/davigr/ClusterWS-Swift'
  s.license          = { :type => 'MIT' }
  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/davigr/ClusterWS-Swift.git', :tag => s.version.to_s }
 
  s.requires_arc = true

  s.ios.deployment_target = '11.0'
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'ClusterWS-Swift' => ['Pod/Assets/*.png']
  }

  s.dependency 'Starscream'
 
end