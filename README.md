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

Download File with progress .
```swift
UrlHandler.sharedInstance.downloadFileWithURL("http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg", progress: { (pre) -> Void in
    println(pre)
    }) { (error, returnObject) -> Void in
        println(returnObject)
}
```

## Author

Rahul Malik, rahul.send89@gmail.com

## License

urlHandler is available under the MIT license. See the LICENSE file for more info.