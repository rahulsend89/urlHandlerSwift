urlHandler
==========

Easy way to work with NSURL in Swift

## Usage

initCache in AppDelegate didFinishLaunchingWithOptions 
```swift
UrlHandler.sharedInstance.initCache()
```


Basic URL request .
```swift
UrlHandler.sharedInstance.basicURL("http://google.com", handler: { (error, returnObject) -> Void in
    if (error != NSError() && returnObject != "notReachable") {
        println(returnObject);
    }else {
        println(error)
    }
})
```
