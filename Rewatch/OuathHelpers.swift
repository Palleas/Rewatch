//
//  OuathHelpers.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-19.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import KeychainSwift

enum OAuthAuthorizeError: ErrorType {
    case InvalidUrl
    case NoCodeInUrl
}

func extractCodeFromURL(url: NSURL) throws -> String {
    guard let comps = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else { throw OAuthAuthorizeError.InvalidUrl }
    guard let code = comps.queryItems?.filter({ $0.name == "code" }).first?.value else { throw OAuthAuthorizeError.NoCodeInUrl }
    
    return code
}

// TODO move
func retrieveToken() -> String? {
    let token = KeychainSwift().get("betaseries-token")
    print("Token = \(token)")
    
    return token
}

func storeToken(token: String) {
    let k = KeychainSwift()
    print("Storing token \(token)")
    k.set(token, forKey: "betaseries-token")
}
