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

protocol EpisodeViewDelegate: class {
    func didTapShareButton()
    func didTapShakeView()
}


class EpisodeView: UIView {
    enum PictureState {
        case Ready
        case Loading
        case Loaded(image: UIImage, bnwImage: UIImage)
    }
    
    var pictureState: PictureState = .Ready {
        didSet {
            switch pictureState {
            case .Ready:
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.episodeImageView.alpha = 0
                    self.bnwEpisodeImageView.alpha = 0
                    self.downloadView.alpha = 0
                })
            case .Loading:
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.downloadView.alpha = 1
                })
            case .Loaded(let image, let bnwImage):
                self.episodeImageView.image = image
                self.bnwEpisodeImageView.image = bnwImage
                self.episodeImageContainer.setNeedsLayout()
                self.episodeImageContainer.layoutIfNeeded()

                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.episodeImageView.alpha = 1
                    self.bnwEpisodeImageView.alpha = 1
                    self.downloadView.alpha = 0
                })

            }
        }
    }
    
    @IBOutlet weak var downloadView: DownloadAnimationView! {
        didSet {
            downloadView.transform = CGAffineTransformMakeScale(0.3, 0.3)
        }
    }
    weak var actionDelegate: EpisodeViewDelegate?
    
    @IBOutlet weak var shakeView: ShakeView! {
        didSet {
            shakeView.shakeButton.addTarget(self, action: Selector("didTapOnShakeView"), forControlEvents: .TouchUpInside)
        }
    }
    
    @IBOutlet weak var episodePictureHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var episodeImageContainer: UIView! {
        didSet {
            episodeImageContainer.backgroundColor = Stylesheet.episodePictureBackgroundImageColor
        }
    }
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.alpha = 0
        }
    }
    
    @IBOutlet weak var bnwEpisodeImageView: UIImageView! {
        didSet {
            bnwEpisodeImageView.alpha = 0
        }
    }

    @IBOutlet weak var episodeContainerView: UIScrollView! {
        didSet {
            episodeContainerView.contentInset = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
            episodeContainerView.hidden = true
            episodeContainerView.delegate = self
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
    
    @IBOutlet weak var shareButton: UIButton!
    var theme: Theme? {
        didSet {
            guard let theme = theme else { return }
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.backgroundColor = theme.backgroundColor
                self.episodeContentView.backgroundColor = theme.backgroundColor
            }

            self.shareButton.tintColor = theme.summaryColor
            self.showNameLabel.textColor = theme.showNameColor
            self.seasonNumberLabel.textColor = theme.seasonNumberColor
            self.episodeNumberLabel.textColor = theme.episodeNumberColor
            self.summaryLabel.textColor = theme.summaryColor
            self.episodeTitleLabel.textColor = theme.episodeTitleColor
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
    
    @IBAction func didTapShareButton(sender: AnyObject) {
        actionDelegate?.didTapShareButton()
    }
    
    func didTapOnShakeView() {
        actionDelegate?.didTapShakeView()
    }
}

extension EpisodeView: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = abs(scrollView.contentOffset.y)

        if offset > 180 {
            bnwEpisodeImageView.alpha = max(180 - abs(180 - offset), 0) / 180
        }

        episodePictureHeightConstraint.constant = abs(min(0, scrollView.contentOffset.y))
    }
}
