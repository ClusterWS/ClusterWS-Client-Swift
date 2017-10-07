# ClusterWS (Node Cluster WebSocket) Client Swift

[![CocoaPods Compatible](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/pod.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![Platform](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/platform.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![swiftyness](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/swift.svg)](https://swift.org/)

ClusterWS - is a minimal **iOS http & real-time** framework which allows to scale WebSocket ([SwiftWebSocket](https://github.com/tidwall/SwiftWebSocket)) - one of the most lightweight WebSocket libraries) between node js clusters and utilize all available CPU.

This is official ios (client) library for [ClusterWS](https://github.com/goriunov/ClusterWS), which is written in Swift 4. All development code can be found in `Source/` folder.

**Current minified version is 1.4MB in ipa file.**

**To be able to use this library you must use [ClusterWS](https://github.com/goriunov/ClusterWS) on the server**

## Installation

ClusterWS-Client-Swift is compatible with
[CocoaPods](http://cocoapods.org/). With CocoaPods, just add this to
your Podfile:

```ruby
pod 'ClusterWS-Client-Swift'
```

## Usage

### 1. Connect to the server

