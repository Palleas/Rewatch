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
    let contentController = MutableProperty<ContentController?>(nil)

    enum AuthenticationControllerError: ErrorType {
        case NoTokenError
    }
    
    private lazy var keychain = KeychainSwift()

    init() {
        let promotedProducer = contentController.producer.ignoreNil().promoteErrors(ContentError)
        promotedProducer
            .flatMap(FlattenStrategy.Latest) { (contentController) -> SignalProducer<Member, ContentError> in
                return contentController.fetchMemberInfos()
            }
            .startWithNext { [weak self] member in
                self?.member.value = member
            }
    }

    func retrieveContentController() {
        guard contentController.value == nil else { return }
        // Snapshot mode enabled
        if let _ = NSProcessInfo.processInfo().arguments.indexOf("snapshot") {
            contentController.value = StaticContentController()
        // Check if the user has a token in keychain
        } else if let token = keychain.get("rewatch-raw-login") {
            let keys = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")!) as! [String: String]

            let controller = BetaseriesContentController(authenticatedClient: AuthenticatedClient(key: keys["BetaseriesAPIKey"]!, token: token))

            self.contentController.value = controller
        }
    }
    
    func saveToken(token: String) {
        keychain.set(token, forKey: "rewatch-raw-login")
    }

    func logout() {
        contentController.value = nil
        member.value = nil
    }
}