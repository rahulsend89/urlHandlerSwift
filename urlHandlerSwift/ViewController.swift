//
//  ViewController.swift
//  urlHandlerSwift
//
//  Created by Rahul Malik on 02/11/14.
//  Copyright (c) 2014 Rahul Malik. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        UrlHandler.sharedInstance.basicURL("http://google.com", handler: { (error, returnObject) -> Void in
        //            if (error != NSError() && returnObject != "notReachable") {
        //                println(returnObject);
        //            }else {
        //                println(error)
        //            }
        //        })
        //        UrlHandler.sharedInstance.downloadFileWithURL("http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg", progress: { (pre) -> Void in
        //            println(pre)
        //            }) { (error, returnObject) -> Void in
        //                println(returnObject)
        //        }
var array:NSArray = ["http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg",
    "http://www.hitswallpapers.com/wp-content/uploads/2014/07/awesome-city-wallpapers-1920x1080-2.jpg",
    "http://awesomewallpaper.files.wordpress.com/2011/09/splendorous1920x1080.jpg"
]
UrlHandler.sharedInstance.downloadListOfListWithArray(array, progress: { (pre, current) -> Void in
    
    println("progress : \(pre) : \(current)")
    
    }) { (error, returnObject, current) -> Void in
        
        println("Completed with : \(returnObject) : \(current)")
}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

