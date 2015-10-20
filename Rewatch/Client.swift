//
//  Client.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import SwiftyJSON
import ReactiveCocoa
import KeychainSwift

class Client: NSObject {
    typealias AuthorizationHandler = (String?, ClientError?) -> Void

    enum ClientError: ErrorType {
        case InternalError
    }
    
    struct Show {
        let id: Int
        let name: String
    }
    
    let key: String
    let secret: String
    let session: NSURLSession
    var token: String?
    
    private var authorizationCompletion: AuthorizationHandler?
    
    init(key: String, secret: String, token: String? = nil) {
        self.key = key
        self.secret = secret
        self.token = token
        
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue())
    }
    
    func authorize(completion: AuthorizationHandler) {
        guard let comps = NSURLComponents(string: "https://www.betaseries.com/authorize") else { return }
        self.authorizationCompletion = completion
        
        var items = [NSURLQueryItem]()
        items.append(NSURLQueryItem(name: "client_id", value: key))
        items.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        
        comps.queryItems = items
        
        if let url = comps.URL {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func handleURL(url: NSURL) {
        do {
            let code = try extractCodeFromURL(url)
            let params = ["client_id":key, "client_secret":secret, "redirect_uri": "rewatch://oauth/handle", "code": code]
            sendRequestToPath("members/access_token", params: params, method: "POST")
                .observeOn(UIScheduler())
                .map({ (payload) -> String in
                    return payload["token"].stringValue
                })
                .flatMap(.Latest, transform: { (token) -> SignalProducer<Show, NSError> in
                    self.token = token
                    return self.fetchShows()
                })
                .startWithNext({ (show) -> () in
                    print("Show #\(show.id) - \(show.name)")
                })
        } catch {
            print("Got error while handling url \(url) : \(error)")
        }
    }
    
    func fetchShows() -> SignalProducer<Show, NSError> {
        return sendRequestToPath("members/infos", params: nil, method: "GET")
            .flatMap(FlattenStrategy.Latest) { (payload) -> SignalProducer<Show, NSError> in
                return SignalProducer<Show, NSError> { sink, disposable in
                    payload["member"]["shows"].arrayValue.forEach({ showNode in
                        let show = Show(id: showNode["id"].intValue, name: showNode["title"].stringValue)
                        sink.sendNext(show)
                    })
                    sink.sendCompleted()
                }
            }
    }
    
    func sendRequestToPath(path: String, params: [String: String]?, method: String) -> SignalProducer<JSON, NSError> {
        let base = "https://api.betaseries.com/\(path)"
        
        let exhangeComponents = NSURLComponents(string: base)!
        exhangeComponents.queryItems = []
        
        if let params = params {
            for (key, value) in params {
                exhangeComponents.queryItems?.append(NSURLQueryItem(name: key, value: value))
            }
        }
        
        let request = NSMutableURLRequest(URL: exhangeComponents.URL!)
        request.setValue(key, forHTTPHeaderField: "X-BetaSeries-Key")
        request.setValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
        request.setValue(token, forHTTPHeaderField: "X-BetaSeries-Token")
        
        if method == "POST" {
            request.HTTPBody = exhangeComponents.query?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            exhangeComponents.query = nil
        }
        request.HTTPMethod = method
        
        return session
            .rac_dataWithRequest(request)
            .map({ data, response in
                return JSON(data: data)
            })
    }
}



