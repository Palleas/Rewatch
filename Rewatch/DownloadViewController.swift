//
//  DownloadViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-21.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class DownloadViewController: UIViewController {
    var client: Client!

    @IBOutlet weak var statusLabel: UILabel! {
        didSet {
            statusLabel.font = Stylesheet.statusFont
            statusLabel.textColor = Stylesheet.statusTextColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "REWATCH"
        view.backgroundColor = Stylesheet.appBackgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

//        client.fetchShows()
//            .flatMap(.Merge, transform: { (show) -> SignalProducer<(Client.Show, Client.Episode), NSError> in
//                return combineLatest(SignalProducer<Client.Show, NSError>(value: show), self.client.fetchEpisodesFromShow(show))
//            })
//            .map({ (show, episode) -> [String: String] in
//                let episodeId = String(episode.id)
//                let seasonNumber =  String(format: "%02d", episode.season)
//                let episodeNumber = String(format: "%02d", episode.episode)
//                
//                return ["show_id": String(show.id),
//                    "show_name": show.name,
//                    "episode_id": episodeId,
//                    "episode_title": episode.title,
//                    "season": seasonNumber,
//                    "episode": episodeNumber,
//                    "summary": episode.summary]
//            
//            })
//            .collect()
//            .flatMap(.Latest, transform: { (results) -> SignalProducer<[[String: String]], NSError> in
//                let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
//                let filePath = (path as NSString).stringByAppendingPathComponent("series.cache")
//                return store(results, toPath: filePath)
//            })
//            .observeOn(UIScheduler())
//            .startWithNext { (results) -> () in
//                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
//            }
    }
}
