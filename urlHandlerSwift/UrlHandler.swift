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
var _completionHandler:((error:NSError?,returnObject:String)->Void)?
var _progressHandler:((Float)->Void)?


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
    func initCache(){
        var URLCache:NSURLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 4 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(URLCache)
    }
    func pathValueWithName(filename:NSString,pathName:NSString)->NSString{
        var documentsDirectory:NSString = "";
        if pathName == "doc" {
            documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent(filename)
        }else if pathName == "temp" {
            documentsDirectory = (NSTemporaryDirectory().stringByAppendingPathExtension(filename))!
        }
        return documentsDirectory;
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
    func basicURL (myURL:String, handler:(error:NSError?,returnObject:String)->Void)->Void{
        if isConnectedToNetwork() {
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
                    var error: NSError? = nil
                    let queue:NSOperationQueue = NSOperationQueue()
                    NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { (reponse, data, error) -> Void in
                        if error == nil{
                            var _cachedResponse:NSCachedURLResponse? = NSCachedURLResponse(response: reponse, data: data)
                            NSURLCache.sharedURLCache().storeCachedResponse(_cachedResponse!, forRequest: request)
                            var string:NSString = NSString(data: data, encoding: NSUTF8StringEncoding)!
                            handler(error: error,returnObject: string);
                        }else{
                            handler(error:error,returnObject:"notReachable")
                        }
                    })
                    
                }
            }
        }else{
            handler(error:NSError(),returnObject:"notReachable")
        }
    }
    
    func downloadFileWithURL(myURL:String,progress:(pre:Float)->Void,handler:(error:NSError?,returnObject:String)->Void)->Void{
        _completionHandler = handler
        _progressHandler = progress
        if isConnectedToNetwork() {
            let mycurrentURL = NSURL(string: myURL);
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.downloading = true;
                self.expectedContentLength = -1;
                self.progressContentLength = 0;
                var filePath:NSString = self.pathValueWithName(myURL.lastPathComponent, pathName: "doc")
                self.mainfilename = filePath
                self.downloadStream = NSOutputStream(toFileAtPath: filePath, append: false)
                var request:NSMutableURLRequest = NSMutableURLRequest(URL:mycurrentURL! ,cachePolicy: NSURLRequestCachePolicy.ReloadRevalidatingCacheData,
                    timeoutInterval: REQUESTTIMEOUT);
                if self.downloadStream == nil {
                    _completionHandler!(error:NSError(),returnObject:"Cannot create downloadStream")
                    self.downloadCompleted(false)
                    return;
                }
                self.downloadStream?.open()
                self.connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
                self.connection?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
                self.connection?.start()
                if self.connection == nil {
                    _completionHandler!(error:NSError(),returnObject:"Cannot create connection")
                    self.downloadCompleted(false)
                    return;
                }
            }
        }else{
            _completionHandler!(error:NSError(),returnObject:"notReachable")
        }
    }
    
    func downloadCompleted(val:Bool)->Void{
        var fileManager:NSFileManager = NSFileManager.defaultManager()
        var errorVal:NSError?;
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
            if fileManager.fileExistsAtPath(self.mainfilename!) {
                fileManager.removeItemAtPath(self.mainfilename!, error: &errorVal)
                if errorVal != nil {
                    _completionHandler!(error:errorVal,returnObject:"removeItemAtPath _ downloadFailed")
                    return;
                }
            }
            _completionHandler!(error:errorVal,returnObject:self.mainfilename!)
        }else{
            if self.mainfilename != nil {
                if fileManager.fileExistsAtPath(self.mainfilename!) {
                    fileManager.removeItemAtPath(self.mainfilename!, error: &errorVal)
                    _completionHandler!(error:errorVal,returnObject:"ConnectionFailed")
                }
            }
        }
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        if response .isKindOfClass(NSHTTPURLResponse .classForCoder()) {
            var statusCode:NSInteger = (response as NSHTTPURLResponse).statusCode
            if statusCode == 200 {
                self.expectedContentLength = response.expectedContentLength
            }else if statusCode >= 400 {
                _completionHandler!(error:NSError(),returnObject:"bad HTTP response status code")
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
        var datawritten = self.downloadStream?.writeData(data)
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
            _completionHandler!(error:NSError(),returnObject:self.mainfilename!);
        }else{
            _completionHandler!(error:NSError(),returnObject:"uploadingCompleted");
        }
    }
    func connection(connection: NSURLConnection, didFailWithError error: NSError){
        _completionHandler!(error:error,returnObject: "downloadingError")
    }
}
