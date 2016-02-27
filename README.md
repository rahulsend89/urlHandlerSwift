urlHandlerSwift
==========
[![Build Status](https://travis-ci.org/rahulsend89/urlHandlerSwift.svg?branch=master)](https://travis-ci.org/rahulsend89/urlHandlerSwift)
[![codecov.io](https://codecov.io/github/rahulsend89/urlHandlerSwift/coverage.svg?branch=master)](https://codecov.io/github/rahulsend89/urlHandlerSwift?branch=master)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=fla )](http://mit-license.org)
[![Platform](http://img.shields.io/badge/platform-ios-lightgrey.svg?style=flat)]
(https://developer.apple.com/resources/) [![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift) 

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
