# ClusterWS (Node Cluster WebSocket) Client Swift

[![CocoaPods Compatible](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/pod-version.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![Platform](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/platform.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![swiftyness](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/swift.svg)](https://swift.org/)

This is official Swift client for ClusterWS.

[ClusterWS](https://github.com/goriunov/ClusterWS) - is a minimal **Node JS http & real-time** framework which allows to scale WebSocket ([uWS](https://github.com/uNetworking/uWebSockets) - one of the fastest WebSocket libraries) between [Node JS Clusters](https://nodejs.org/api/cluster.html) and utilize all available CPU.

**This library requires [ClusterWS](https://github.com/goriunov/ClusterWS) on the server**

## Installation

ClusterWS-Client-Swift is compatible with
[CocoaPods](http://cocoapods.org/). With CocoaPods, just add this to
your Podfile:

```ruby
pod 'ClusterWS-Client-Swift'
```

## Usage

### 1. Importing library

When you installed the library, you have to declare it in your swift file:

```swift
import ClusterWS_Client_Swift
```

### 2. Connecting

```swift
let webSocket = ClusterWS(url: "host", port: portNumber)
webSocket.delegate = self
webSocket.connect()
```

*WebSocket can be initialized with more options*

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
*/
```

### 3.  Listen on events

To listen on event use `'on'` method which is provided by ClusterWS:

```swift
/**
    ClusterWS public function:
    func on(event: String, completion: @escaping CompletionHandler) {}
*/

/**
    event name: string - can be any string you wish
    data: any - is what you send from the client
*/

webSocket.on(event: "myevent") { (data) in
    // in here you can write any logic
}
```

*Also `webSocket` gets **Reserved Events** such as `'connect'`, `'disconnect'` and `'error'`*

```swift
webSocket.on('connect') { (data) in
// in here you can write any logic
}

/**
    err: any - display the problem with your weboscket
*/

webSocket.on('error') { (data) in
// in here you can write any logic
}

/**
    code: number - represent the reason in number
    reason: string - reason why your socket was disconnected
*/

webSocket.on('disconnect') { (data) in
// in here you can write any logic
}
```

### 4. Send an event

To send events to the server use `send` method witch is provided by `webSocket`

```swift
/**
    event name: string - can be any string you wish (client must listen on this event name)
    data: any - is what you want to send to the client
*/
webSocket.send(event: "myevent", data: data)
```

*Avoid emitting **Reserved Events** such as `'connect'`, `'connection'`, `'disconnect'` and `'error'`. Also avoid emitting  event and events with `'#'` at the start.*

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

/**
    WebSocketReadyState states:
    case connecting: 'The connection is not yet open'
    case open: 'The connection is open and ready to communicate'
    case closing: 'The connection is in the process of closing'
    case closed: 'The connection is closed or couldn't be opened'
*/
```

## Pub/Sub

You can subscribe, watch, unsubscribe and publish to the channels

```swift
/**
    channel name: string - can be any string you wish
*/

//subscribe to channel
var channel = webSocket.subscribe(channelName: "channel")

/**
    data: any - is what you get when you or some one else publish to the channel
*/

//listen on the data from channel
channel.watch { (data) in
// in here you can write any logic
}

/**
    data: any - is what you want to publish to the channel (everyone who is subscribe will get it)
*/

channel.publish(data: "some data")

/**
    This method is used to unsubscribe from the channel
*/

channel.unsubscribe()

/**
    Also you can chain everything in one expression
*/

var channel = webSocket.subscribe(channelName: "channel").watch { (data) in
// in here you can write any logic
}.publish(data: "some data")
```
**To make sure that user is connected to the server before subscribing, do it on `connect` event or on any other events which you emit from the server, otherwise subscription may not work properly**

*Docs is still under development.*

## Happy codding !!! :sunglasses:
