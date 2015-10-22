//
//  ShowsViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-16.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class ShowsViewController: UIViewController {

    var client: Client!
    var shows: [[String: String]] = []
    
    @IBOutlet weak var showNameLabel: UILabel!
    @IBOutlet weak var episodeTitleLabel: UILabel!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.becomeFirstResponder()
        
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        let filePath = (path as NSString).stringByAppendingPathComponent("series.cache")
        shows = NSArray(contentsOfFile: filePath) as! [[String: String]]
        
        title = "Rewatch"
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
    }
}
