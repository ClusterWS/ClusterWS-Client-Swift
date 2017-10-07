Pod::Spec.new do |s|
  s.name             = 'ClusterWS-Client-Swift'
  s.version          = '1.0.1'
  s.summary          = 'Native iOS client for ClusterWS'
 
  s.description      = 'Native iOS client for ClusterWS. Simple and easy to use sockets & socket stream library with channel communication and asynchronous calls.'
 
  s.homepage         = 'https://github.com/davigr/ClusterWS-Client-Swift'
 s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Copyright (c) 2015 Roman Baitaliuk <romanbaital@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
    LICENSE
  }
  s.author           = { '<Roman Baitaliuk>' => '<romanbaital@gmail.com>' }
  s.source           = { :git => 'https://github.com/davigr/ClusterWS-Client-Swift.git', :tag => s.version.to_s }
 
  s.requires_arc = true

  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources'
  s.libraries = 'z'
  #s.dependency "SwiftWebSocket"
 
end