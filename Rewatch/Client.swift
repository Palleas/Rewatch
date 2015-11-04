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
    
    struct Episode {
        let id: Int
        let title: String
        let episode: Int
        let season: Int
        let summary: String
    }
    
    let key: String
    let secret: String
    let session: NSURLSession
    var token: String?
    
    var authenticated: Bool {
        get {
            return token != nil
        }
    }

    lazy private var urlPipe = Signal<NSURL, NSError>.pipe()
    
    init(key: String, secret: String, token: String? = nil) {
        self.key = key
        self.secret = secret
        self.token = token
        
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue())
    }
    
    // Opens the browser and sends a code
    func authorize() -> SignalProducer<String, NSError> {
        let comps = NSURLComponents(string: "https://www.betaseries.com/authorize")!
        
        var items = [NSURLQueryItem]()
        items.append(NSURLQueryItem(name: "client_id", value: key))
        items.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        
        comps.queryItems = items
        
        if let url = comps.URL {
            UIApplication.sharedApplication().openURL(url)
        }

        return SignalProducer(signal: urlPipe.0.map({ (url) -> String in
            return try! extractCodeFromURL(url)
        }))
    }
    
    func completeSigninWithURL(url: NSURL) {
        urlPipe.1.sendNext(url)
    }
    
    func requestAccessToken(code: String) -> SignalProducer<String, NSError> {
        let params = ["client_id":key, "client_secret":secret, "redirect_uri": "rewatch://oauth/handle", "code": code]
        return sendRequestToPath("members/access_token", params: params, method: "POST")
            .map({ (payload) -> String in
                return payload["token"].stringValue
            })
    }
    
    func authenticate() -> SignalProducer<Client, NSError> {
        return authorize()
            .flatMap(FlattenStrategy.Latest, transform: { (code) -> SignalProducer<Client, NSError> in
                return self.requestAccessToken(code)
                    .flatMap(FlattenStrategy.Latest, transform: { (token) -> SignalProducer<Client, NSError> in
                        self.token = token
                        return SignalProducer(value: self)
                    })
            })
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
    
    func fetchEpisodesFromShow(showId: String) -> SignalProducer<Episode, NSError> {
        let params = ["id": showId]
        return sendRequestToPath("shows/episodes", params: params, method: "GET")
            .flatMap(FlattenStrategy.Latest, transform: { (payload) -> SignalProducer<Episode, NSError> in
                return SignalProducer<Episode, NSError> { sink, disposable in
                    payload["episodes"].arrayValue.forEach({ episodeNode in
                        let episode = Episode(id: episodeNode["id"].intValue, title: episodeNode["title"].stringValue, episode: episodeNode["episode"].intValue, season: episodeNode["season"].intValue, summary: episodeNode["description"].stringValue)
                        sink.sendNext(episode)
                    })
                    sink.sendCompleted()
                }
            })
    }
    
    func fetchPictureForEpisodeId(id: String) -> SignalProducer<UIImage, NSError> {
        let request = requestForPath("pictures/episodes", params: ["id" : id, "width": "640"], method: "GET")
        return session
            .rac_dataWithRequest(request)
            .flatMap(.Latest, transform: { (data, response) -> SignalProducer<NSData, NSError> in
                if let response = response as? NSHTTPURLResponse where response.statusCode == 404 {
                    return SignalProducer.empty
                }
                
                return SignalProducer(value: data)
            })
            .map({ data in UIImage(data: data)! })
    }
    
    func sendRequestToPath(path: String, params: [String: String]?, method: String) -> SignalProducer<JSON, NSError> {
        let request = requestForPath(path, params: params, method: method)
        
        return session
            .rac_dataWithRequest(request)
            .map({ data, _ in
                return JSON(data: data)
            })
    }
    
    func requestForPath(path: String, params: [String: String]?, method: String) -> NSURLRequest {
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

        return request
    }
}



