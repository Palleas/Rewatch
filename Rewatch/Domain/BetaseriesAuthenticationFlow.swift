//
//  BetaseriesAuthenticationFlow.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-08.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import BetaSeriesKit
import ReactiveCocoa

enum AuthenticationFlowError: ErrorType {
    case ClientError
}

class BetaseriesAuthenticationFlow {
    typealias ResultType = BetaSeriesKit.AuthenticatedClient
    typealias FlowErrorType = AuthenticationFlowError
    
    private let flowPipe = Signal<BetaseriesAuthenticationFlow.ResultType, BetaseriesAuthenticationFlow.FlowErrorType>.pipe()
    private let client: BetaSeriesKit.Client
    private let secret: String

    
    var signalProducer : SignalProducer<BetaseriesAuthenticationFlow.ResultType, BetaseriesAuthenticationFlow.FlowErrorType> {
        return createSignalProducer()
    }
    
    init(client: BetaSeriesKit.Client, secret: String) {
        self.client = client
        self.secret = secret
    }
    
    private func createSignalProducer() -> SignalProducer<BetaseriesAuthenticationFlow.ResultType, BetaseriesAuthenticationFlow.FlowErrorType> {
        return client
            .authenticate(secret)
            .mapError({ _ in return AuthenticationFlowError.ClientError })
    }
}