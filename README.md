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

### 2. Connect to the server

```swift
let webSocket = ClusterWS(url: "host", port: portNumber)
webSocket.delegate = self
webSocket.connect()
```

*WebSocket can be initialized with more options*

```swift
let webSocket = ClusterWS(url: "host", port: portNumber, autoReconnect: true, reconnectionInterval: 5.0, reconnectionAttempts: 10)

/** Options information
url: '{string} url of the server without http or https',
port: '{number} port of the server',
autoReconnect: '{boolean} allow to auto-reconnect to the server on lost connection (default false)',
reconnectionInterval: '{number} how often it will try to reconnect in seconds (default 5.0)',
reconnectionAttempts: '{number} how many attempts, 0 means without limit (default 0)'
**/
```

### 3.  Listen on events from the server

To listen on event use `'on'` method which is provided by ClusterWS:

```swift
/** ClusterWS public function
func on(event: String, completion: @escaping CompletionHandler) {}
**/

webSocket.on(event: "myevent") { (data) in
    print(data)
}
```

*You can listen on any event which you emit from the server, also you can listen on **Reserved events** which are emitted by the server automatically.*

*Data which you get in `CompletionHandler` is what you send with event, you can send `any type of data`.*

***Reserved events**: `'connect'`, `'error'`, `'disconnect'`*

### 4. Emit an event

To emit an event to the server you should use `send` method which is provided by ClusterWS:

```swift
webSocket.send(event: "myevent", data: data)
```

*`'data'` can be any type you want such as `array`, `string`, `object`, `...`*

***Try to avoid emitting reserved events:** `'connect'`, `'error'`, `'disconnect'`, or any events which start with `'#'`*

### 5. ClusterWSDelegate methods

```swift
//called when WebSocket become open / connected
func onConnect()

//called on WebSocket disconnect / close event
func onDisconnect(code: Int?, reason: String?)

//called when WebSocket is error out
func onError(error: Error)
```

*Don't forget to assign class delegate to listen for those events*

```swift
webSocket.delegate = self
```

### 6. Other methods of ClusterWS class

```swift
//WebSocket force disconnect
func disconnect(closeCode: Int? = nil, reason: String? = nil) { }

//get current WebSocket state
func getState() -> WebSocketReadyState { }

/** WebSocketReadyState states
case connecting: 'The connection is not yet open'

case open: 'The connection is open and ready to communicate'

case closing: 'The connection is in the process of closing'

case closed: 'The connection is closed or couldn't be opened'
**/
```

## Pub/Sub

### 1. Subscribe watch and publish to the channels

You can subscribe to `any channels`:

```swift
//subscribe to channel
var channel = webSocket.subscribe(channelName: "channel")
```

After you subscribe to the `channel` you will be able to get all messages which are published to this `channel` and you will also be able to publish your messages there:

```swift
//listen on the data from channel
channel.watch { (data) in
    print(data)
}

//publish data to channel
channel.publish(data: "some data")
```

Or you can chain everything:

```swift
var channel = webSocket.subscribe(channelName: "channel").watch { (data) in
    print(data)
}.publish(data: "some data")
```

*`'data'` can be any type you want such as `array`, `string`, `object`, `...`*

**To make sure that user is connected to the server before subscribing, do it on `connect` event or on any other events which you emit from the server, otherwise subscription may not work properly**

# Happy codding !!! :sunglasses:


