//
//  GenerateDeepLinkViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import Mustache
import Swifter

class GenerateDeepLinkViewController: UIViewController {
    typealias Completion = (Result) -> Void
    
    enum Result {
        case Completed
        case Error
    }
    
    lazy private(set) var template: Template? = {
        return try? Template(named: "generate-deeplink")
    }()
    
    lazy private(set) var server = HttpServer()
    
    let episode: StoredEpisode
    let completion: Completion
    
    init(episode: StoredEpisode, completion: Completion) {
        self.episode = episode
        self.completion = completion
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = GenerateDeepLinkView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidBecomeActive:"), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        do {
            let payload = ["episode_id": String(episode.id),
                "show_name": episode.show?.name ?? "[No name]",
                "episode_title": episode.title,
                "season_number": String(episode.season),
                "episode_number": String(episode.episode),
                "summary": episode.summary ?? "No summary"]
            
            guard let result = try template?.render(Box(payload)) else { return }
            guard let encodedPage = result.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else { return }
            
            server["/save"] = { _ in
                return HttpResponse.MovedPermanently("data:text/html;charset=utf-8," + encodedPage)
            }
            
            try server.start()
            
            UIApplication.sharedApplication().openURL(NSURL(string: "http://localhost:8080/save")!)
        } catch {
            print("Unable to generate page: \(error)")
            
            completion(.Error)
        }
    }

    func applicationDidBecomeActive(note: NSNotification) {
        server.stop()
        completion(.Completed)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)

        server.stop()
    }
}
