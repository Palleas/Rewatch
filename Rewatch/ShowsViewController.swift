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

    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
            scrollView.backgroundColor = Stylesheet.showBackgroundColor
        }
    }
    @IBOutlet weak var shakeLabel: UILabel! {
        didSet {
            shakeLabel.font = Stylesheet.textFont
            shakeLabel.textColor = .whiteColor()
        }
    }
    
    @IBOutlet weak var showNameLabel: UILabel! {
        didSet {
            showNameLabel.font = Stylesheet.showNameTextFont
            showNameLabel.textColor = .whiteColor()
        }
    }
    
    @IBOutlet weak var episodeTitleLabel: UILabel! {
        didSet {
            episodeTitleLabel.font = Stylesheet.episodeTitleTextFont
            episodeTitleLabel.textColor = .whiteColor()
        }
    }

    @IBOutlet weak var seasonNumberLabel: UILabel! {
        didSet {
            seasonNumberLabel.font = Stylesheet.episodeNumberFont
            seasonNumberLabel.textColor = Stylesheet.episodeNumberTextColor
        }
    }
    
    @IBOutlet weak var episodeNumberLabel: UILabel! {
        didSet {
            episodeNumberLabel.font = Stylesheet.seasonNumbertextFont
            episodeNumberLabel.textColor = Stylesheet.episodeNumberTextColor
        }
    }

    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.font = Stylesheet.textFont
            descriptionLabel.textColor = .whiteColor()
        }
    }

    @IBOutlet weak var episodePictureView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackViewWidth.constant = view.frame.width - 40
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
        
        showNameLabel.text = show["show_name"]
        episodeTitleLabel.text = show["episode_title"]
        
        client
            .fetchPictureForEpisodeId(show["episode_id"]!)
            .observeOn(UIScheduler())
            .startWithNext { (image) -> () in
                self.episodePictureView.image = image
            }
    }
}
