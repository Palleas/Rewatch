//
//  RewatchTests.swift
//  RewatchTests
//
//  Created by Romain Pouclet on 2015-10-20.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import XCTest

class RewatchTests: XCTestCase {
    
    func testCodeIsExtracted() {
        let url = NSURL(string: "rewatch://oauth/handle?code=BreakingBadIsOverrated")!
        let code = try! extractCodeFromURL(url)
        XCTAssertEqual("BreakingBadIsOverrated", code)
    }
    
    func testErrorIsThrownWhenURLIsInvalid() {
        do {
            let url = NSURL(string: "rewatch://oauth/handle")!
            let _ = try extractCodeFromURL(url)
        } catch OAuthAuthorizeError.NoCodeInUrl {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Expected 'OAuthAuthorizeError.NoCodeInUrl' error, got \(error)")
        }
    }
}
