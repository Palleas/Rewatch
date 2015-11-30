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
    var creditsView: UIView? {
        didSet {
            if let creditsView = creditsView {
                insertSubview(creditsView, atIndex: 0)
                creditsView.translatesAutoresizingMaskIntoConstraints = false
                creditsView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
                creditsView.leftAnchor.constraintEqualToAnchor(leftAnchor).active = true
                creditsView.rightAnchor.constraintEqualToAnchor(rightAnchor).active = true
                creditsView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true
            } else {
                creditsView?.removeFromSuperview()
            }
        }
    }
    var currentView: UIView?
    var containerView = UIView()
    var leftContainerConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: CGRectZero)
        
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraintEqualToAnchor(topAnchor).active = true
        leftContainerConstraint = containerView.leftAnchor.constraintEqualToAnchor(leftAnchor)
        leftContainerConstraint?.active = true
        
        containerView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        containerView.bottomAnchor.constraintEqualToAnchor(bottomAnchor).active = true

        containerView.addSubview(placeholderView)
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        placeholderView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        placeholderView.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        placeholderView.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true

        backgroundColor = Stylesheet.appBackgroundColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func transitionToView(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(view)
        
        view.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active = true
        view.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active = true
        view.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor).active = true

        UIView.transitionFromView(placeholderView, toView: view, duration: 0.5, options: .TransitionCrossDissolve) { (completed) -> Void in
            self.currentView = view
        }
    }
    
    func toggleCredits() {
        if let leftContainerConstraint = self.leftContainerConstraint where leftContainerConstraint.constant > 0 {
            self.leftContainerConstraint?.constant = 0
        } else {
            self.leftContainerConstraint?.constant = 200
        }

        UIView.animateWithDuration(0.3) { () -> Void in
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

}
