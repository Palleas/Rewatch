//
//  EpisodeView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-27.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class EpisodeView: UIView {
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
            backgroundColor = theme.backgroundColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clearColor()
        theme = RedTheme()
    }
}
