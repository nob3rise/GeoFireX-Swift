# GeoFireX-Swift

[![CI Status](https://img.shields.io/travis/Nob/GeoFireX-Swift.svg?style=flat)](https://travis-ci.org/Nob/GeoFireX-Swift)
[![Version](https://img.shields.io/cocoapods/v/GeoFireX-Swift.svg?style=flat)](https://cocoapods.org/pods/GeoFireX-Swift)
[![License](https://img.shields.io/cocoapods/l/GeoFireX-Swift.svg?style=flat)](https://cocoapods.org/pods/GeoFireX-Swift)
[![Platform](https://img.shields.io/cocoapods/p/GeoFireX-Swift.svg?style=flat)](https://cocoapods.org/pods/GeoFireX-Swift)

This framework helps you to get geometry data from Firebase with geohash. Basic logic is the same as [GeoFireX](https://github.com/codediodeio/geofirex) by [codediodeio](https://github.com/codediodeio).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

GeoFireX-Swift query result is returned as Combine, so you have to make a subscriber to get result. within() makes Publisher, you can make a subscriber just by executing sink().

``` Swift
import Firebase
import Combine
import GeoFireX_Swift

let client = GeoFireClient()
let query = client.query("markers")
let center = FirePoint(geopoint: GeoPoint(latitude: 35.68123620000001, longitude: 139.7671248))

var result : [[String:Any]]!

let subscriber = query.within(center: center, radius: 1.5, field: "geography", opts: GeoQueryOptions(units: .kilometer, log: true))?.sink( receiveCompletion: { completion in
  switch completion {
  case .finished:
    print(".sink() received the completion:", String(describing: completion))
    break
  case .failure(let anError):
    print("received the error: ", anError)
    break
  }
}) { (dataList) in
  result = dataList
}
```

## Requirements

- iOS 13.0 later
- Conbine
- Firebase

## Installation

GeoFireX-Swift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GeoFireX-Swift'
```

## Run UnitTest

You have to setup Firebase emulator to invoke Unit Test. Official guide is [here](https://firebase.google.com/docs/rules/emulator-setup).

### Setup Steps

#### 1. install firebase-tool  
```$ npm install -g firebase-tools```

#### 2. install Firebase emulatoer
```$ firebase setup:emulators:firestore```

#### 3. move firebase configuration directory
```$ mv firebase```

#### 4. start emulator
```$ firebase emulators:start --only firestore```

#### 5. run Unit Tests

## Features

### Not implemented yet

- Promise Binding
- Converting result to JSON

## Author

Nob,
[Twitter](nobushige.asahi@gmail.com)
[Portfolio](https://portfolio-e3de3.firebaseapp.com/)

## License

GeoFireX-Swift is available under the MIT license. See the LICENSE file for more info.
