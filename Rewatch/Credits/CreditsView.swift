//
//  CreditsView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-29.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

struct CreditsItem {
    let title: String
    let value: String
    let URL: NSURL?
}

class CreditsItemView: UIStackView {
    let titleLabel = UILabel()
    let valueLabel = UIButton()

    init(title: String, value: String) {
        super.init(frame: CGRectZero)
        
        axis = .Vertical
        
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(titleLabel)
        valueLabel.setTitle(value, forState: .Normal)
        valueLabel.contentHorizontalAlignment = .Left
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(valueLabel)
        
        titleLabel.textColor = Stylesheet.creditsTitleColor
        valueLabel.setTitleColor(Stylesheet.creditsValueColor, forState: .Normal)
        titleLabel.font = Stylesheet.creditsTitleFont
        valueLabel.titleLabel?.font = Stylesheet.creditsValueFont
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CreditsViewDelegate: class {
    func didSelectCreditItem(item: CreditsItem)
}

class CreditsView: UIView {
    
    let title = UILabel()
    let creditsContainer = UIStackView()
    let items = [CreditsItem(title: NSLocalizedString("DESIGN", comment: "Design"), value: "Adrien Heury", URL: NSURL(string: "http://www.adrien-heury.net")),
        CreditsItem(title: NSLocalizedString("DEVELOPMENT", comment: "Development"), value: "Romain Pouclet", URL: NSURL(string: "http://romain-pouclet.com")),
        CreditsItem(title: NSLocalizedString("API", comment: "API"), value: "Betaseries.com", URL: NSURL(string: "https://betaseries.com")),
        CreditsItem(title: NSLocalizedString("VERSION", comment: "Version"), value: "1.0 (beta)", URL: nil)
    ]
    
    weak var delegate: CreditsViewDelegate?
    
    init() {
        super.init(frame: CGRectZero)
        creditsContainer.axis = .Vertical
        creditsContainer.spacing = 20

        items.forEach { (item) -> () in
            let view = CreditsItemView(title: item.title, value: item.value)
            creditsContainer.addArrangedSubview(view)
            
            if let _ = item.URL {
                view.valueLabel.addTarget(self, action: #selector(CreditsView.didTapCreditItem(_:)), forControlEvents: .TouchUpInside)
            }
        }

        addSubview(creditsContainer)
        creditsContainer.translatesAutoresizingMaskIntoConstraints = false
        creditsContainer.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -20).active = true
        creditsContainer.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 20).active = true
        creditsContainer.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 0.5).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didTapCreditItem(sender: UIButton) {
        if let item = sender.superview as? CreditsItemView, let index = creditsContainer.arrangedSubviews.indexOf(item) {
            delegate?.didSelectCreditItem(items[index])
        }
    }
}
