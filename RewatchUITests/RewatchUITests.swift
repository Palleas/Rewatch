//
//  RewatchUITests.swift
//  RewatchUITests
//
//  Created by Romain Pouclet on 2015-12-30.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import XCTest

class RewatchUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = ["snapshot"]

        XCUIDevice.sharedDevice().orientation = .FaceUp
        setupSnapshot(app)
        app.launch()
        
    }
    
    func testSnapshots() {
        
        let app = XCUIApplication()
        snapshot("01-shake-screen")
        
        app.buttons["ShakeButton"].tap()
        snapshot("02-tv-show")
        
        app.navigationBars.matchingIdentifier("REWATCH").buttons["Options"].tap()
        snapshot("03-settings")
        
    }
}
