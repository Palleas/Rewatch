//
//  ViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-15.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import Keys

class ViewController: UIViewController {
    let keys = RewatchKeys()
    var token: String? {
        didSet {
            print("New token is \(token)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func authenticate(sender: AnyObject) {
        guard let comps = NSURLComponents(string: "https://www.betaseries.com/authorize") else { return }

        var items = [NSURLQueryItem]()
        items.append(NSURLQueryItem(name: "client_id", value: keys.betaseriesAPIKey()))
        items.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        
        comps.queryItems = items
        
        if let url = comps.URL {
            print("Opening URL \(url)")
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func handleURL(url: NSURL) {
        print("Handling url = \(url)")
        guard let comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { return }
        guard let code = comps.queryItems?.filter({ $0.name == "code" }).first?.value else { return }
        
        let exhangeComponents = NSURLComponents(string: "https://api.betaseries.com/members/access_token")!
        exhangeComponents.queryItems = []
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "client_id", value: keys.betaseriesAPIKey()))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "client_secret", value: keys.betaseriesAPISecret()))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "redirect_uri", value: "rewatch://oauth/handle"))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "Content-Type", value: "application/x-www-form-urlencoded"))
        exhangeComponents.queryItems?.append(NSURLQueryItem(name: "code", value: code))
        
        guard let body = exhangeComponents.query else { return }
        guard let exchangeURL = exhangeComponents.URL else { return }

        exhangeComponents.query = nil
            
        let request = NSMutableURLRequest(URL: exchangeURL)
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        request.HTTPMethod = "POST"
        request.setValue(keys.betaseriesAPIKey(), forHTTPHeaderField: "X-BetaSeries-Key")
        request.setValue("2.4", forHTTPHeaderField: "X-BetaSeries-Version")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data, let payload = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) {
                print(payload)
                if let token = payload["token"] as? String {
                    self.token = token
                }
            }
        }
        task.resume()
    }
}

