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
    typealias Element = StoredEpisode
    let wrapped: Element
    
    init(wrapped: Element) {
        self.wrapped = wrapped
    }
    
    var showName : String { get { return wrapped.show?.name ?? "" } }
    var title : String { get { return wrapped.title ?? "" } }
    var season : String { get { return String(wrapped.season) } }
    var number : String { get { return String(wrapped.episode) } }
    var description : String { get { return wrapped.summary ?? "" } }
}

class EpisodeViewController: UIViewController {
    let themes: [Theme] = [WhiteTheme(), RedTheme(), DarkTheme()]

    var episodeView: EpisodeView {
        get {
            return view as! EpisodeView
        }
    }
    
    let client: Client
    let persistenceController: PersistenceController
    let analyticsController: AnalyticsController
    
    var episodes: [StoredEpisode] = []
    
    init(client: Client, persistenceController: PersistenceController, analyticsController: AnalyticsController) {
        self.client = client
        self.persistenceController = persistenceController
        self.analyticsController = analyticsController
        
        super.init(nibName: nil, bundle: nil)
        title = "REWATCH"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let leftButton = UIButton(type: .Custom)
        leftButton.setImage(UIImage(named: "Hamburger"), forState: .Normal)
        leftButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let rightButton = UIButton(type: .Custom)
        rightButton.setImage(UIImage(named: "Options"), forState: .Normal)
        rightButton.addTarget(self, action: Selector("didTapSettingsButton:"), forControlEvents: .TouchUpInside)
        rightButton.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = persistenceController.allEpisodes()
        
        if episodes.count == 0 {
            let downloadViewController = DownloadViewController(client: client, downloadController: DownloadController(client: client, persistenceController: persistenceController))
            let navigation = UINavigationController(rootViewController: downloadViewController)
            presentViewController(navigation, animated: true, completion: nil)
        } else {
            becomeFirstResponder()
        }
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
        guard episodes.count > 0 else { return }
        
        let index = Int(arc4random_uniform(UInt32(episodes.count)))
        let randomEpisode = episodes[index]
        let episode = EpisodeWrapper(wrapped: randomEpisode)
        
        episodeView.theme = themes[Int(arc4random_uniform(UInt32(themes.count)))]
        episodeView.episode = episode

        episodeView.shakeView.hidden = true
        episodeView.episodeContainerView.hidden = false
        episodeView.episodeImageView.hidden = false
        
        client.fetchPictureForEpisodeId(String(randomEpisode.id))
            .on(completed: { self.analyticsController.trackEvent(.Shake) })
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
    
    func didTapSettingsButton(button: UIButton) {
        let settings = SettingsViewController(client: client, persistenceController: persistenceController)
        presentViewController(settings, animated: true, completion: nil)
    }
}
