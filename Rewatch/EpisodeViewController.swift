//
//  EpisodeViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class EpisodeWrapper: EpisodeViewData {
    typealias Element = [String:String]
    let wrapped: Element
    
    init(wrapped: Element) {
        self.wrapped = wrapped
    }
    
    var showName : String { get { return wrapped["show_name"]! } }
    var title : String { get { return wrapped["episode_title"]! } }
    var season : String { get { return wrapped["season"]! } }
    var number : String { get { return wrapped["episode"]! } }
    var description : String { get { return wrapped["summary"]! } }

}

class EpisodeViewController: UIViewController {
    let themes: [Theme] = [WhiteTheme(), RedTheme(), DarkTheme()]

    var episodeView: EpisodeView {
        get {
            return view as! EpisodeView
        }
    }
    
    let client: Client
    var shows = [[String: String]]()
    
    init(client: Client) {
        self.client = client
        
        super.init(nibName: nil, bundle: nil)
        title = "REWATCH"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
//        let filePath = (path as NSString).stringByAppendingPathComponent("series.cache")
//        shows = NSArray(contentsOfFile: filePath) as! [[String: String]]

        let leftButton = UIButton(type: .Custom)
        leftButton.setImage(UIImage(named: "Hamburger"), forState: .Normal)
        leftButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let rightButton = UIButton(type: .Custom)
        rightButton.setImage(UIImage(named: "Options"), forState: .Normal)
        rightButton.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        becomeFirstResponder()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            fetchRandomItem()
        }
    }
    
    func fetchRandomItem() {
        let index = Int(arc4random_uniform(UInt32(shows.count)))
        let show = shows[index]
        let episode = EpisodeWrapper(wrapped: show)
        
        episodeView.theme = themes[Int(arc4random_uniform(UInt32(themes.count)))]
        episodeView.episode = episode

        episodeView.shakeView.hidden = true
        episodeView.episodeContainerView.hidden = false
        episodeView.episodeImageView.hidden = false
        
        client.fetchPictureForEpisodeId(show["episode_id"]!)
            .flatMap(FlattenStrategy.Latest, transform: { (image) -> SignalProducer<(UIImage, UIImage), NSError> in
                return SignalProducer(value: (image, convertToBlackAndWhite(image)))
            })
            .observeOn(UIScheduler())
            .startWithNext { (image) -> () in
                self.episodeView.episodeImageContainer.hidden = false
                self.episodeView.episodeImageView.image = image.0
                self.episodeView.bnwEpisodeImageView.image = image.1
            }

        
    }
}
