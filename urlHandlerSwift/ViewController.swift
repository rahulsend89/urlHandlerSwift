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
        UrlHandler.sharedInstance.basicURL("http://google.com", handler: { (error, returnObject) -> Void in
            println(returnObject);
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

