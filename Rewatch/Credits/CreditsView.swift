//
//  CreditsView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-29.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class CreditsItem: UIStackView {
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    init(title: String, value: String) {
        super.init(frame: CGRectZero)
        
        axis = .Vertical
        
        titleLabel.text = title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(titleLabel)
        valueLabel.text = value
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(valueLabel)
        
        titleLabel.textColor = Stylesheet.creditsTitleColor
        valueLabel.textColor = Stylesheet.creditsValueColor
        titleLabel.font = Stylesheet.creditsTitleFont
        valueLabel.font = Stylesheet.creditsValueFont
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CreditsView: UIView {
    
    let title = UILabel()
    let creditsContainer = UIStackView()
    
    init() {
        super.init(frame: CGRectZero)
        creditsContainer.axis = .Vertical
        creditsContainer.spacing = 20

        creditsContainer.addArrangedSubview(CreditsItem(title: "Design", value: "Adrien Heury"))
        creditsContainer.addArrangedSubview(CreditsItem(title: "Development", value: "Romain Pouclet"))
        creditsContainer.addArrangedSubview(CreditsItem(title: "API", value: "Betaseries.com"))
        creditsContainer.addArrangedSubview(CreditsItem(title: "Version", value: "1.0"))

        addSubview(creditsContainer)
        creditsContainer.translatesAutoresizingMaskIntoConstraints = false
        creditsContainer.bottomAnchor.constraintEqualToAnchor(bottomAnchor, constant: -20).active = true
        creditsContainer.leftAnchor.constraintEqualToAnchor(leftAnchor, constant: 20).active = true
        creditsContainer.widthAnchor.constraintEqualToAnchor(widthAnchor, multiplier: 0.5).active = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
