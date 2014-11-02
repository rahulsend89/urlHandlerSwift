//
//  UrlHandler.swift
//  urlHandlerSwift
//
//  Created by Rahul Malik on 02/11/14.
//  Copyright (c) 2014 Rahul Malik. All rights reserved.
//

import Foundation
var REQUESTTIMEOUT:NSTimeInterval = 10;
class UrlHandler:NSObject{
    class var sharedInstance : UrlHandler {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : UrlHandler? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = UrlHandler()
        }
        return Static.instance!
    }
    func basicURL (myURL:String, handler:(error:NSError,returnObject:String)->Void)->Void{
        let mycurrentURL = NSURL(string: myURL);
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            var request:NSMutableURLRequest = NSMutableURLRequest(URL:mycurrentURL! ,cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData,
                timeoutInterval: REQUESTTIMEOUT);
            var cachedResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request);
            if cachedResponse != nil {
                var returndata:NSData = cachedResponse!.data;
                var returnString = String(NSString(data: returndata, encoding: NSUTF8StringEncoding)!)
                handler(error: NSError(),returnObject: returnString);
            }else{
                var reponse:AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil;
                var error: NSErrorPointer = nil
                let queue:NSOperationQueue = NSOperationQueue()
                NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (reponse, data, error) -> Void in
                    if error == nil{
                        var _cachedResponse:NSCachedURLResponse? = NSCachedURLResponse(response: reponse, data: data)
                        NSURLCache.sharedURLCache().storeCachedResponse(_cachedResponse!, forRequest: request)
                        var string:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
                        handler(error: NSError(),returnObject: string);
                    }else{
                        handler(error:error,returnObject:"notReachable")
                    }
                })
                
            }
        }
    }
}