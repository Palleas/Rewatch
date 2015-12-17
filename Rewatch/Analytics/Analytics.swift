//
//  Analytics.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-13.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import Mixpanel

enum AnalyticsEvent {
    case Shake
    case Credits
    case Settings
    case ManualSync
    case LogOut
    case SupportMail
    case SupportTwitter
    case OpenURL(NSURL)
}

extension AnalyticsEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .Shake: return "shake"
        case .Credits: return "credits"
        case .Settings: return "settings"
        case .ManualSync: return "manual_sync"
        case .LogOut: return "log_out"
        case .SupportMail: return "support_mail"
        case .SupportTwitter: return "support_twitter"
        case .OpenURL(_): return "open_url"
        }
    }
}

protocol AnalyticsController {
    func trackEvent(event: AnalyticsEvent)
}

class MixpanelAnalyticsController: AnalyticsController {
    let mixpanel: Mixpanel
    
    init(mixpanel: Mixpanel) {
        self.mixpanel = mixpanel
    }
    
    func trackEvent(event: AnalyticsEvent) {
        let properties: [NSObject : AnyObject]?
        switch event {
        case .OpenURL(let url):
            properties = ["url": url.description]
        default:
            properties = [:]
        }
        mixpanel.track(event.description, properties: properties)
    }
}

