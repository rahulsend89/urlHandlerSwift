urlHandlerSwift
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


Multiple File Downloader with progress .
```swift
var array:NSArray = ["http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg",
    "http://www.hitswallpapers.com/wp-content/uploads/2014/07/awesome-city-wallpapers-1920x1080-2.jpg",
    "http://awesomewallpaper.files.wordpress.com/2011/09/splendorous1920x1080.jpg"
]
UrlHandler.sharedInstance.downloadListOfListWithArray(array, progress: { (pre, current) -> Void in
    
    println("progress : \(pre) : \(current)")
    
    }) { (error, returnObject, current) -> Void in
        
        println("Completed with : \(returnObject) : \(current)")
}
```

## Author

Rahul Malik, rahul.send89@gmail.com

## License

urlHandlerSwift is available under the MIT license. See the LICENSE file for more info.