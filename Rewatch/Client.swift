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

class Client: NSObject {
    typealias AuthorizationHandler = (String?, ClientError?) -> Void

    enum ClientError: ErrorType {
        case InternalError
    }
    
    struct Show {
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
        guard let comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return }
        guard let code = comps.queryItems?.filter({ $0.name == "code" }).first?.value else { return }
        
        let exhangeComponents = NSURLComponents(string: "https://api.betaseries.com/members/access_token")!
        exhangeComponents.queryItems = []
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "client_id", value: key))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "client_secret", value: secret))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "Content-Type", value: "application/x-www-form-urlencoded"))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "code", value: code))
        
        guard let body = exhangeComponents.query else { return }
        guard let exchangeURL = exhangeComponents.URL else { return }
        
        exhangeComponents.query = nil
        
        let request = NSMutableURLRequest(URL: exchangeURL)
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue(key, forHTTPHeaderField: "X-BetaSeries-Key")
        request.setValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data, let payload = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                print(payload)
                if let token = payload["token"] as? String {
                    self.token = token
                    self.authorizationCompletion?(token, nil)
                }
            }
        }
        task.resume()
    }
    
    func fetchShows() -> SignalProducer<Show, NSError> {
        let request = NSMutableURLRequest(URL:  NSURL(string: "https://api.betaseries.com/shows/list")!)
        request.setValue(key, forHTTPHeaderField: "X-BetaSeries-Key")
        request.setValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
        request.setValue(token, forHTTPHeaderField: "X-BetaSeries-Token")
        
        return session.rac_dataWithRequest(request)
            .map({ data, response in
                return JSON(data: data)
            })
            .flatMap(FlattenStrategy.Latest) { (payload) -> SignalProducer<Show, NSError> in
                return SignalProducer<Show, NSError> { sink, disposable in
                    payload["shows"].arrayValue.forEach({ showNode in
                        let show = Show(name: showNode["title"].stringValue)
                        sink.sendNext(show)
                    })
                    sink.sendCompleted()
                }
            }
    }
    
    func dataToJSON(data: NSData) -> JSON {
        return JSON(data: data)
    }
}

