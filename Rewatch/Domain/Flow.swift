//
//  AuthenticationFlow.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-08.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol Flow {
    typealias ResultType
    typealias FlowErrorType: ErrorType

    func startFlowInViewController(presentingViewController: UIViewController) -> Signal<Self.ResultType, Self.FlowErrorType>
    
}

