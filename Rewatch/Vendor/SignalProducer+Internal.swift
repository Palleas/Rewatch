//
//  SignalProducer+Internal.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2016-03-30.
//  Copyright © 2016 Perfectly-Cooked. All rights reserved.
//

import ReactiveCocoa
import enum Result.NoError

extension SignalProducer {

    func demoteErrors() -> SignalProducer<Value, NoError> {
        return flatMapError { _ in SignalProducer<Value, NoError>.empty }
    }

}
