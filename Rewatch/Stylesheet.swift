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
    
    // Fonts
    static let titleFont = UIFont(name: "Roboto-Bold", size: 14)!
    static let textFont = UIFont(name: "Roboto", size: 18)!
    
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
