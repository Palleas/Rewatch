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
    enum AuthenticationControllerError: ErrorType {
        case NoTokenError
    }
    
    private lazy var keychain = KeychainSwift()

    func retrieveContentController() -> ContentController? {
        if let token = keychain.get("rewatch-raw-login") {
            let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]

            return BetaseriesContentController(authenticatedClient: AuthenticatedClient(key: keys["BetaseriesAPIKey"]!, token: token))
        }
        
        return nil
    }
    
    func saveToken(token: String) {
        keychain.set(token, forKey: "rewatch-raw-login")
    }

}