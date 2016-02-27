//
//  UrlHandler.swift
//  urlHandlerSwift
//
//  Created by Rahul Malik on 02/11/14.
//  Copyright (c) 2014 Rahul Malik. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

var REQUESTTIMEOUT:NSTimeInterval = 10;
var _completionHandler:((error:ErrorType?,returnObject:String)->Void)?
var _progressHandler:((Float)->Void)?

var _multiCompletionHandler:((error:ErrorType?,returnObject:String,current:Int)->Void)?
var _multiProgressHandler:((pre:Float,current:Int)->Void)?
var _currentVal:Int = 0

extension NSOutputStream {
    func writeData(data: NSData) -> Int {
        var totalBytesWritten = 0
        data.enumerateByteRangesUsingBlock() {
            buffer, range, stop in
            var bytes = UnsafePointer<UInt8>(buffer)
            var bytesWritten = 0
            var bytesLeftToWrite = range.length
            while bytesLeftToWrite > 0 {
                bytesWritten = self.write(bytes, maxLength: bytesLeftToWrite)
                if bytesWritten < 0 {
                    stop.initialize(true)
                    totalBytesWritten = -1
                    return
                }
                bytes += bytesWritten
                bytesLeftToWrite -= bytesWritten
                totalBytesWritten += bytesWritten
            }
        }
        return totalBytesWritten
    }
}


class UrlHandler:NSObject{
    var downloading:Bool = false
    var connection:NSURLConnection?
    var expectedContentLength:IntMax?
    var progressContentLength:Int?
    var mainfilename:NSString?
    var downloadStream:NSOutputStream?
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
    private func makeError(text:String="")->NSError{
        let code:Int = 404;
        return NSError(domain: "HTTPTask", code: code, userInfo: [NSLocalizedDescriptionKey: text])
    }
    func initCache(){
        let URLCache:NSURLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 4 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
    }
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func pathValueWithName(filename:NSString,pathName:NSString)->NSString{
        var documentsDirectory:NSString = "";
        if pathName == "doc" {
            documentsDirectory = "\(getDocumentsDirectory())\(filename)"
        }else if pathName == "temp" {
            documentsDirectory = "\(NSTemporaryDirectory())\(filename)"
        }
        return documentsDirectory;
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    func basicURL (myURL:String, handler:(error:NSError?,returnObject:String)->Void)->Void{
        if isConnectedToNetwork() {
            let mycurrentURL = NSURL(string: myURL);
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:mycurrentURL! ,cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData,
                    timeoutInterval: REQUESTTIMEOUT);
                let cachedResponse = NSURLCache.sharedURLCache().cachedResponseForRequest(request);
                if cachedResponse != nil {
                    let returndata:NSData = cachedResponse!.data;
                    let returnString = String(NSString(data: returndata, encoding: NSUTF8StringEncoding)!)
                    handler(error: nil,returnObject: returnString);
                }else{
                    let queue:NSOperationQueue = NSOperationQueue()
                    NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (reponse, data, error) -> Void in
                        if error == nil{
                            let _cachedResponse:NSCachedURLResponse? = NSCachedURLResponse(response: reponse!, data: data!)
                            NSURLCache.sharedURLCache().storeCachedResponse(_cachedResponse!, forRequest: request)
                            let string:NSString = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                            handler(error: error,returnObject: string as String);
                        }else{
                            handler(error:error,returnObject:"notReachable")
                        }
                    })
                    
                }
            }
        }else{
            handler(error:self.makeError("notReachable"),returnObject:"")
        }
    }
    
    func downloadFileWithURL(myURL:String,progress:(pre:Float)->Void,handler:(error:ErrorType?,returnObject:String)->Void)->Void{
        _completionHandler = handler
        _progressHandler = progress
        if isConnectedToNetwork() {
            let mycurrentURL = NSURL(string: myURL);
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.downloading = true;
                self.expectedContentLength = -1;
                self.progressContentLength = 0;
                let filePath:NSString = self.pathValueWithName((mycurrentURL?.lastPathComponent)!, pathName: "doc")
                self.mainfilename = filePath
                self.downloadStream = NSOutputStream(toFileAtPath: filePath as String, append: false)
                let request:NSMutableURLRequest = NSMutableURLRequest(URL:mycurrentURL! ,cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData,
                    timeoutInterval: REQUESTTIMEOUT);
                if self.downloadStream == nil {
                    _completionHandler!(error:self.makeError("Cannot create downloadStream"),returnObject:"")
                    self.downloadCompleted(false)
                    return;
                }
                self.downloadStream?.open()
                self.connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
                self.connection?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
                self.connection?.start()
                if self.connection == nil {
                    _completionHandler!(error:self.makeError("Cannot create connection"),returnObject:"")
                    self.downloadCompleted(false)
                    return;
                }
            }
        }else{
            _completionHandler!(error:self.makeError("notReachable"),returnObject:"")
        }
    }
    
    func downloadListOfListWithArray(fileList:NSArray,progress:(pre:Float,current:Int)->Void,handler:(error:ErrorType?,returnObject:String,current:Int)->Void)->Void{
        if fileList.count==0 {
            return;
        }
        _multiCompletionHandler = handler
        _multiProgressHandler = progress
        if isConnectedToNetwork() {
            let myURL:String = fileList[0] as! String;
//            let tempURL:NSURL = NSURL(string: myURL)!
//            let filename:NSString = tempURL.lastPathComponent!
            UrlHandler.sharedInstance.downloadFileWithURL(myURL, progress: { (pre) -> Void in
                _multiProgressHandler!(pre: pre,current: _currentVal)
                }, handler: { (error, returnObject) -> Void in
                    _multiCompletionHandler!(error: error, returnObject: returnObject, current: _currentVal)
                    _currentVal++;
                    
                    let array:NSMutableArray = NSMutableArray(array: fileList as [AnyObject],copyItems:true)
                    array.removeObjectAtIndex(0)
                    self.downloadListOfListWithArray((array as NSArray), progress: _multiProgressHandler!, handler: _multiCompletionHandler!)
            })
        }else{
            _multiCompletionHandler!(error:makeError("notReachable"),returnObject:"notReachable",current: 0)
        }
    }

    func basicFormURL(myURL:NSString,urlMethod:NSString,dictionary:NSDictionary){
        
    }
    func downloadCompleted(val:Bool)->Void{
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        if self.connection != nil {
            if !val {
                self.connection?.cancel()
            }
            self.connection = nil
        }
        if self.downloadStream != nil {
            self.downloadStream?.close()
            self.downloadStream = nil
        }
        self.downloading = false
        if val {
            if fileManager.fileExistsAtPath(self.mainfilename! as String) {
                do {
                    try fileManager.removeItemAtPath(self.mainfilename! as String)
                }catch{
                    _completionHandler!(error:error,returnObject:"removeItemAtPath _ downloadFailed")
                }
            }
            _completionHandler!(error:nil,returnObject:self.mainfilename! as String)
        }else{
            if self.mainfilename != nil {
                if fileManager.fileExistsAtPath(self.mainfilename as! String) {
                    do {
                        try fileManager.removeItemAtPath(self.mainfilename! as String)
                    }catch{
                        _completionHandler!(error:error,returnObject:"ConnectionFailed")
                    }
                    
                }
            }
        }
    }
    
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        if response .isKindOfClass(NSHTTPURLResponse .classForCoder()) {
            let statusCode:NSInteger = (response as! NSHTTPURLResponse).statusCode
            if statusCode == 200 {
                self.expectedContentLength = response.expectedContentLength
            }else if statusCode >= 400 {
                _completionHandler!(error:nil,returnObject:"bad HTTP response status code")
                self.downloadCompleted(false)
            }
        }else{
            self.expectedContentLength = -1;
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData){
        if !self.downloading {
            return;
        }
        let datawritten = self.downloadStream?.writeData(data)
        if datawritten == -1{
            self.downloadCompleted(false)
        }
        self.progressContentLength! += datawritten!
        _progressHandler!(Float(Float(self.progressContentLength!)/Float(self.expectedContentLength!)))
    }
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int){
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection){
        if (self.mainfilename != nil) {
            _completionHandler!(error:nil,returnObject:self.mainfilename! as String);
        }else{
            _completionHandler!(error:nil,returnObject:"uploadingCompleted");
        }
    }
    func connection(connection: NSURLConnection, didFailWithError error: NSError){
        _completionHandler!(error:error,returnObject: "downloadingError")
    }
}
