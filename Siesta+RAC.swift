//
//  SiestaRAC.swift
//  orderin
//
//  Created by David O'Reilly on 2016/04/27.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation
import Siesta
import ReactiveSwift
import ReactiveCocoa

extension Resource {

    func rac_request(method: RequestMethod, json: JSONConvertible) -> SignalProducer<Entity<Any>, RequestError> {
        return SignalProducer { observer, disposable in
            let request = self.request(method, json: json).onSuccess { data in
                observer.send(value: data)
                observer.sendCompleted()
            }.onFailure { error in
                observer.send(error: error)
            }

            _ = disposable.observeEnded {
                request.cancel()
            }
        }
    }
}
