//
//  EpisodeViewController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-28.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import ReactiveCocoa
import AVFoundation
import Swifter

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
    
    lazy private(set) var randomSound: AVAudioPlayer? = {
        guard let path = NSBundle.mainBundle().pathForResource("pop_drip", ofType: "aif") else { return nil }
        let url = NSURL.fileURLWithPath(path)
        return try? AVAudioPlayer(contentsOfURL: url)
    }()
    
    lazy private(set) var shakeSignal = Signal<(), NoError>.pipe()
    
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
        leftButton.addTarget(self, action: Selector("didTapCreditsButton:"), forControlEvents: .TouchUpInside)
        leftButton.sizeToFit()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let rightButton = UIButton(type: .Custom)
        rightButton.setImage(UIImage(named: "Options"), forState: .Normal)
        rightButton.addTarget(self, action: Selector("didTapSettingsButton:"), forControlEvents: .TouchUpInside)
        rightButton.sizeToFit()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        episodeView.actionDelegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        episodes = persistenceController.allEpisodes()
        
        if episodes.count == 0 {
            let downloadViewController = DownloadViewController(client: client, downloadController: DownloadController(client: client, persistenceController: persistenceController))
            let navigation = UINavigationController(rootViewController: downloadViewController)
            rootViewController?.presentViewController(navigation, animated: true, completion: nil)
        } else {
            becomeFirstResponder()
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            shakeSignal.1.sendNext(())
            fetchRandomItem()
        }
    }
    
    func fetchRandomItem() {
        guard episodes.count > 0 else { return }
        
        let index = Int(arc4random_uniform(UInt32(episodes.count)))
        let randomEpisode = episodes[index]
        
        presentEpisode(randomEpisode)
    }
    
    func presentEpisode(randomEpisode: StoredEpisode) {
        let episode = EpisodeWrapper(wrapped: randomEpisode)

        self.randomSound?.play()

        episodeView.theme = themes[Int(arc4random_uniform(UInt32(themes.count)))]
        episodeView.episode = episode
        episodeView.pictureState = .Ready
    
        episodeView.shakeView.hidden = true
        episodeView.episodeContainerView.hidden = false
        episodeView.episodeImageView.hidden = false
        
        client.fetchPictureForEpisodeId(String(randomEpisode.id))
            .takeUntil(shakeSignal.0)
            .on(started: {
                    UIScheduler().schedule({ () -> () in
                        self.episodeView.pictureState = .Loading
                    })
                },
                completed: { self.analyticsController.trackEvent(.Shake) })
            .flatMap(FlattenStrategy.Latest, transform: { (image) -> SignalProducer<(UIImage, UIImage), NSError> in
                return SignalProducer(value: (image, convertToBlackAndWhite(image)))
            })
            .observeOn(UIScheduler())
            .startWithNext { (image) -> () in
                self.episodeView.pictureState = .Loaded(image: image.0, bnwImage: image.1)
            }
    }
    
    func didTapSettingsButton(button: UIButton) {
        let settings = UINavigationController(rootViewController: SettingsViewController(client: client, persistenceController: persistenceController, completion: { () -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(settings, animated: true, completion: nil)
    }
    
    func didTapCreditsButton(button: UIButton) {
        rootViewController?.toogleCredits()
    }
}

extension EpisodeViewController: EpisodeViewDelegate {
    func didTapShareButton() {
        guard let episode = episodeView.episode as? EpisodeWrapper else { return }

        let activity = UIActivityViewController(activityItems: [episode.wrapped], applicationActivities: [GenerateDeeplinkActivity()])
        presentViewController(activity, animated: true, completion: nil)
    }
}
