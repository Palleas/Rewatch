//
//  Analytics.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-11-13.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import Mixpanel

enum AnalyticsEvent: String {
    case Shake = "shake"
    case Credits = "credits"
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
        mixpanel.track(event.rawValue)
    }
}

