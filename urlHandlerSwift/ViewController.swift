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
//               UrlHandler.sharedInstance.basicURL("https://httpbin.org/user-agent", handler: { (error, returnObject) -> Void in
//                   if (error == nil && returnObject != "") {
//                       print("Return Object \(returnObject) : \(error)");
//                   }else {
//                       print(error)
//                   }
//               })
                UrlHandler.sharedInstance.downloadFileWithURL("http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg", progress: { (pre) -> Void in
                    print("progress : \(pre)")
                    }) { (error, returnObject) -> Void in
                        print(returnObject)
                }
//                let array:NSArray = ["http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg",
//                    "http://www.hitswallpapers.com/wp-content/uploads/2014/07/awesome-city-wallpapers-1920x1080-2.jpg",
//                    "http://awesomewallpaper.files.wordpress.com/2011/09/splendorous1920x1080.jpg"
//                ]
//                UrlHandler.sharedInstance.downloadListOfListWithArray(array, progress: { (pre, current) -> Void in
//        
//                    print("progress : \(pre) : \(current)")
//        
//                    }) { (error, returnObject, current) -> Void in
//        
//                        print("Completed with : \(returnObject) : \(current)")
//                }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

