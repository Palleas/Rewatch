//
//  EpisodeView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-27.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

protocol EpisodeViewData {
    var showName : String { get }
    var title : String { get }
    var season : String { get }
    var number : String { get }
    var description : String { get }
}

class EpisodeView: UIView {
    @IBOutlet weak var shakeView: ShakeView!
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.hidden = true
        }
    }

    @IBOutlet weak var episodeContainerView: UIScrollView! {
        didSet {
            episodeContainerView.contentInset = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
            episodeContainerView.hidden = true
        }
    }
    
    @IBOutlet weak var episodeContentView: UIView!
    
    @IBOutlet var showNameLabel: UILabel! {
        didSet {
            showNameLabel.font = Stylesheet.showNameTextFont
            showNameLabel.textColor = .whiteColor()
        }
    }
    
    @IBOutlet var seasonNumberLabel: UILabel! {
        didSet {
            seasonNumberLabel.font = Stylesheet.episodeNumberFont
            seasonNumberLabel.textColor = Stylesheet.episodeNumberTextColor
        }
    }
    
    @IBOutlet var episodeNumberLabel: UILabel! {
        didSet {
            episodeNumberLabel.font = Stylesheet.seasonNumbertextFont
            episodeNumberLabel.textColor = Stylesheet.episodeNumberTextColor
        }
    }

    @IBOutlet var episodeTitleLabel: UILabel! {
        didSet {
            episodeTitleLabel.font = Stylesheet.episodeTitleTextFont
            episodeTitleLabel.textColor = .whiteColor()
        }
    }

    @IBOutlet var summaryLabel: UILabel! {
        didSet {
            summaryLabel.font = Stylesheet.textFont
            summaryLabel.textColor = .whiteColor()
        }
    }
    
    var theme: Theme? {
        didSet {
            guard let theme = theme else { return }
            
            showNameLabel.textColor = theme.showNameColor
            seasonNumberLabel.textColor = theme.seasonNumberColor
            episodeNumberLabel.textColor = theme.episodeNumberColor
            summaryLabel.textColor = theme.summaryColor
            episodeTitleLabel.textColor = theme.episodeTitleColor
            episodeContentView.backgroundColor = theme.backgroundColor
            backgroundColor = theme.backgroundColor
        }
    }
    
    var episode: EpisodeViewData? {
        didSet {
            guard let episode = episode else { return }
            showNameLabel.text = episode.showName
            episodeTitleLabel.text = episode.title
            seasonNumberLabel.text = "S\(episode.season)"
            episodeNumberLabel.text = "E\(episode.number)"
            summaryLabel.text = episode.description
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = Stylesheet.commonBackgroundColor
    }
}
