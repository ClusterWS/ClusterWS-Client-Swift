Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Swift'
  s.version          = '0.1.0'
  s.summary          = 'Native iOS client for ClusterWS'
 
  s.description      = 'Native iOS client for ClusterWS'
 
  s.homepage         = 'https://github.com/davigr/ClusterWS-Swift'
  s.license          = { :type => 'MIT' }
  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/davigr/ClusterWS-Swift.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/*.swift'

  s.dependency 'Starscream'
 
end