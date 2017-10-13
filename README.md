# ClusterWS Client Swift

[![CocoaPods Compatible](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/pod-version.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![Platform](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/platform.svg)](http://cocoadocs.org/docsets/ClusterWS-Client-Swift/)
[![swiftyness](https://github.com/davigr/ClusterWS-Client-Swift/blob/master/Resources/swift.svg)](https://swift.org/)

## Overview
This is official Swift client for [ClusterWS](https://github.com/ClusterWS/ClusterWS).

[ClusterWS](https://github.com/ClusterWS/ClusterWS) - is a minimal **Node JS http & real-time** framework which allows to scale WebSocket ([uWS](https://github.com/uNetworking/uWebSockets) - one of the fastest WebSocket libraries) between **Workers** in [Node JS Cluster](https://nodejs.org/api/cluster.html) and utilize all available CPU.

**This library requires [ClusterWS](https://github.com/ClusterWS/ClusterWS) on the server**

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

If you want to set auto reconnection use setReconnection method

```swift
webSocket.setReconnection(autoReconnect: true, reconnectionIntervalMin: 1.0, reconnectionIntervalMax: 5.0, reconnectionAttempts: 0)

/**
    autoReconnect: '{boolean} allow to auto-reconnect to the server on lost connection (default false)',
    reconnectionIntervalMin: '{number} how often it will try to reconnect in seconds (default 1.0)',
    reconnectionIntervalMax: '{number} how often it will try to reconnect in seconds (default 5.0)',
    reconnectionAttempts: '{number} how many attempts, 0 means without limit (default 0)'
*/
```

### 3. ClusterWSDelegate methods

```swift
//called when WebSocket become open / connected
func onConnect() {}

//called on WebSocket disconnect / close event
func onDisconnect(code: Int?, reason: String?) {}

//called when WebSocket is error out
func onError(error: Error) {}
```

*Don't forget to assign class delegate to listen for those events*

```swift
webSocket.delegate = self
```

### 4.  Listen on events

To listen on event use `'on'` method which is provided by ClusterWS:

```swift
/**
    event name: string - can be any string you wish
    data: any - is what you send from the client
*/
webSocket.on(event: "myevent") { (data) in
    // in here you can write any logic
}
```

### 5. Send an event

To send events to the server use `send` method witch is provided by `webSocket`

```swift
/**
    event name: string - can be any string you wish (client must listen on this event name)
    data: any - is what you want to send to the client
*/
webSocket.send(event: "myevent", data: data)
```

*Avoid emitting **Reserved Events** such as `'connect'`, `'connection'`, `'disconnect'` and `'error'`. Also avoid emitting  event and events with `'#'` at the start.*

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
let channel = webSocket.subscribe(channelName: "channel name")

/**
    data: any - is what you get when you or some one else publish to the channel
*/
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
let channel = webSocket.subscribe(channelName: "channel").watch { (data) in
    // in here you can write any logic
}.publish(data: "some data")

/**
    You can get channel by channel name only if you were subscribed before
    You can use any methods as with usual channel
*/
webSocket.getChannel(byName: 'channel name')

/**
    You can get an array of all channels
*/
let channels = webSocket.getChannels()

```
**To make sure that user is connected to the server before subscribing, do it on `connect` event or on any other events which you emit from the server, otherwise subscription may not work properly**

## See Also
* [Medium ClusterWS](https://medium.com/clusterws)

*Docs are still under development. If you have found any errors please submit pull request or leave issue*

## Happy coding !!! :sunglasses:
