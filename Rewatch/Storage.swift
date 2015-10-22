//
//  Storage.swift
//  Rewatch
//
//  Created by Romain Pouclet on 2015-10-20.
//  Copyright © 2015 Perfectly-Cooked. All rights reserved.
//

import Foundation
import ReactiveCocoa

func store<T>(content: [T], toPath path: String) -> SignalProducer<[T], NSError> {
    return SignalProducer<[T], NSError> { sink, disposable in
        let contentToStore = content as! AnyObject as! NSArray
        if contentToStore.writeToFile(path, atomically: true) {
            sink.sendNext(content)
            sink.sendCompleted()
        } else {
            sink.sendError(NSError(domain: "Storage", code: 0, userInfo: nil))
        }
    }
}