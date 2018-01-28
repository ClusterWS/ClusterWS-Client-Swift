Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Client-Swift'
  s.version          = '2.0.2'
  s.summary          = 'Native Swift client library for ClusterWS'
 
  s.description      = 'Official Swift Client library for ClusterWS - lightweight, fast and powerful framework for building horizontally & vertically scalable WebSocket applications in Node.js'
 
  s.homepage         = 'https://github.com/ClusterWS/ClusterWS-Client-Swift'
  s.license          = { :type => 'MIT' }

  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/ClusterWS/ClusterWS-Client-Swift.git', :tag => s.version.to_s }
 
  s.requires_arc = true
  s.documentation_url = 'https://github.com/ClusterWS/ClusterWS-Client-Swift/blob/master/Docs/README.md'

  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  
  s.source_files = 'Core'
  s.libraries = 'z'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests'
    test_spec.requires_app_host = true
  end  

  #s.dependency "SwiftWebSocket"
 
end