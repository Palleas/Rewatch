//
//  Client.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class Client: NSObject {
    typealias AuthorizationHandler = (String?, ClientError?) -> Void

    enum ClientError: ErrorType {
        case InternalError
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
                if let _ = payload["token"] as? String {

                }
            }
        }
        task.resume()
    }
    
    func fetchShows() {
        let request = NSMutableURLRequest(URL:  NSURL(string: "https://api.betaseries.com/shows/list")!)
        request.setValue(key, forHTTPHeaderField: "X-BetaSeries-Key")
        request.setValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
        request.setValue("", forHTTPHeaderField: "X-BetaSeries-Token")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data, let payload = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                print(payload)
            }
        }
        task.resume()
    }
}
