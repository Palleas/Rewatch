//
//  AuthenticationController.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-20.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import ReactiveCocoa
import KeychainSwift
import class BetaSeriesKit.AuthenticatedClient

class AuthenticationController {
    let member = MutableProperty<Member?>(nil)

    enum AuthenticationControllerError: ErrorType {
        case NoTokenError
    }
    
    private lazy var keychain = KeychainSwift()

    func retrieveContentController() -> ContentController? {
        if let token = keychain.get("rewatch-raw-login") {
            let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]

            let controller = BetaseriesContentController(authenticatedClient: AuthenticatedClient(key: keys["BetaseriesAPIKey"]!, token: token))
            controller.fetchMemberInfos().startWithNext { memberInfos in
                self.member.value = memberInfos
            }
            return controller
        }
        
        return nil
    }
    
    func saveToken(token: String) {
        keychain.set(token, forKey: "rewatch-raw-login")
    }

    func logout() {
    
    }
}