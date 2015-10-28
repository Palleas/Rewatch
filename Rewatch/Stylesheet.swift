//
//  Stylesheet.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-22.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import UIKit
import HEXColor

class Stylesheet: NSObject {
    // Colors
    static let navigationBarTextColor = UIColor(rgba: "#222222")
    static let navigationBarTintColor = UIColor.whiteColor()
    static let commonBackgroundColor = UIColor(rgba: "#222222")
    static let appBackgroundColor = UIColor.blackColor()
    
    static let showBackgroundColor = UIColor(rgba: "#F74D40")
    static let episodeNumberTextColor = UIColor(rgba: "#222222")
    static let seasonNumberTextColor = UIColor(rgba: "#222222")
    
    static let buttonBorderColor = UIColor(rgba: "#979797")
    static let explainationTextColor = UIColor(rgba: "#F74E40")
    static let statusTextColor = UIColor.whiteColor()
    
    // Fonts
    static let titleFont = UIFont(name: "Roboto-Bold", size: 14)!
    static let textFont = UIFont(name: "Roboto", size: 18)!
    static let showNameTextFont = UIFont(name: "Roboto", size: 21)!
    static let episodeTitleTextFont = UIFont(name: "Roboto-Bold", size: 26)!
    static let episodeNumberFont = UIFont(name: "Roboto-Light", size: 50)!
    static let seasonNumbertextFont = UIFont(name: "Roboto-Light", size: 50)!
    
    static let buttonFont = UIFont(name: "Roboto-Bold", size: 16)!
    static let explainationFont = UIFont(name: "Roboto-Light", size: 15)!
    static let statusFont = UIFont(name: "Roboto", size: 15)!

    func apply() {
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Stylesheet.navigationBarTextColor, NSFontAttributeName: Stylesheet.titleFont]
        UINavigationBar.appearance().barTintColor = Stylesheet.navigationBarTintColor
        UINavigationBar.appearance().tintColor = Stylesheet.navigationBarTintColor
        UINavigationBar.appearance().backgroundColor = Stylesheet.navigationBarTintColor
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: .Any, barMetrics: .Default)
    }
}


extension UIFont {
    class func robotoWithSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Roboto", size: size)!
    }
}
