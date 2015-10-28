//
//  ShowsViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-16.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ShowsViewController: UIViewController {

    var client: Client!
    var shows: [[String: String]] = []
    
    @IBOutlet weak var shakeView: ShakeView!

    @IBOutlet weak var episodeView: EpisodeView!
    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInset = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var shakeLabel: UILabel! {
        didSet {
            shakeLabel.font = Stylesheet.textFont
            shakeLabel.textColor = .whiteColor()
        }
    }

    @IBOutlet weak var episodePictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackViewWidth.constant = view.frame.width
    }
        
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.title = "REWATCH"
        view.backgroundColor = Stylesheet.commonBackgroundColor
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()
        
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        let filePath = (path as NSString).stringByAppendingPathComponent("series.cache")
        shows = NSArray(contentsOfFile: filePath) as! [[String: String]]
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
        
        shakeView.hidden = true
        episodeView.hidden = false
        
        episodeView.showNameLabel.text = show["show_name"]
        episodeView.episodeTitleLabel.text = show["episode_title"]
        episodeView.summaryLabel.text = "Do you see any Teletubbies in here? Do you see a slender plastic tag clipped to my shirt with my name printed on it? Do you see a little Asian child with a blank expression on his face sitting outside on a mechanical helicopter that shakes when you put quarters in it? No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb. Do you see any Teletubbies in here? Do you see a slender plastic tag clipped to my shirt with my name printed on it? Do you see a little Asian child with a blank expression on his face sitting outside on a mechanical helicopter that shakes when you put quarters in it? No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb.Do you see any Teletubbies in here? Do you see a slender plastic tag clipped to my shirt with my name printed on it? Do you see a little Asian child with a blank expression on his face sitting outside on a mechanical helicopter that shakes when you put quarters in it? No? Well, that's what you see at a toy store. And you must think you're in a toy store, because you're here shopping for an infant named Jeb."

        client
            .fetchPictureForEpisodeId(show["episode_id"]!)
            .observeOn(UIScheduler())
            .startWithNext { (image) -> () in
                self.episodePictureView.image = image
            }
    }
}
