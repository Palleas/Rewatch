//
//  GenerateDeepLinkView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-24.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class GenerateDeepLinkView: UIView {
    enum State {
        case Loading
        case Loaded
    }
    
    var state = State.Loading {
        didSet {
            
        }
    }
    
    let spinnerContainer = UIView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    init() {
        super.init(frame: CGRectZero)
        
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        addSubview(spinnerContainer)
        spinnerContainer.translatesAutoresizingMaskIntoConstraints = false
        spinnerContainer.backgroundColor = .blackColor()
        spinnerContainer.widthAnchor.constraintEqualToConstant(80).active = true
        spinnerContainer.heightAnchor.constraintEqualToConstant(80).active = true
        spinnerContainer.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        spinnerContainer.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
        
        spinnerContainer.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.centerXAnchor.constraintEqualToAnchor(spinnerContainer.centerXAnchor).active = true
        spinner.centerYAnchor.constraintEqualToAnchor(spinnerContainer.centerYAnchor).active = true
        spinner.startAnimating()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
