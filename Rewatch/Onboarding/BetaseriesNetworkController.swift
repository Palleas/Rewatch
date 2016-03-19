//
//  BetaseriesAdapter.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-02-14.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import BetaSeriesKit

class BetaseriesNetworkController: NetworkController {
    let client: AuthenticatedClient

    init(client: AuthenticatedClient) {
        self.client = client
    }
    
}