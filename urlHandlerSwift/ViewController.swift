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
        UrlHandler.sharedInstance.downloadFileWithURL("http://wfiles.brothersoft.com/a/awesome-ice-block_178817-1920x1080.jpg", progress: { (pre) -> Void in
            println(pre)
            }) { (error, returnObject) -> Void in
                println(returnObject)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

