//
//  RootView.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-05.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit

class RootView: UIView {
    let placeholderView = PlaceholderView()
    
    init() {
        super.init(frame: CGRectZero)
        
        addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        placeholderView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        placeholderView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        placeholderView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true

        backgroundColor = Stylesheet.appBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionToView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        view.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        view.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
        view.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
        
        UIView.transitionFromView(placeholderView, toView: view, duration: 0.5, options: .TransitionCrossDissolve) { (completed) -> Void in

        }
    }

}
