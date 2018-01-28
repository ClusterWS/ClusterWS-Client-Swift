Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Client-Swift'
  s.version          = '2.0.5'
  s.summary          = 'Swift Client for ClusterWS'
  s.description      = 'Swift Client for ClusterWS - lightweight, fast and powerful framework for building horizontally & vertically scalable WebSocket applications in Node.js'
  s.homepage         = 'https://github.com/ClusterWS/ClusterWS-Client-Swift'
  s.license          = { :type => 'MIT' }
  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/ClusterWS/ClusterWS-Client-Swift.git', :tag => s.version.to_s }
  s.requires_arc = true
  s.documentation_url = 'https://github.com/ClusterWS/ClusterWS-Client-Swift/blob/2.0.5/Docs/README.md'

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"

  s.source_files = 'Source'
  s.libraries = 'z'

  # s.test_spec 'Tests' do |test_spec|
  #   test_spec.source_files = 'Tests'
  # end

  #s.dependency "SwiftWebSocket"
 
end