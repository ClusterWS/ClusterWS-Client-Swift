# ClusterWS (Node Cluster WebSocket) Client Swift

[![CocoaPods Compatible](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/pod-version.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
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

### 1. Import library

When you installed the library, you have to declare it in your swift file:

```swift
import ClusterWS_Client_Swift
```

### 1. Connect to the server

```swift
let webSocket = ClusterWS(url: "host", port: portNumber)
webSocket.delegate = self
webSocket.connect()
```

**WebSocket can be initialized with more options**

```swift
let webSocket = ClusterWS(url: "host", port: portNumber, autoReconnect: true, reconnectionInterval: 5.0, reconnectionAttempts: 10)
```

```swift
/**
url: '{string} url of the server without http or https',
port: '{number} port of the server',
autoReconnect: '{boolean} allow to auto-reconnect to the server on lost connection (default false)',
reconnectionInterval: '{number} how often it will try to reconnect in seconds (default 5.0)',
reconnectionAttempts: '{number} how many attempts, 0 means without limit (default 0)'
**/
```




