//
//  NSObject+Siesta.swift
//
//  Created by David O'Reilly on 2016/04/28.
//  Copyright © 2016 David O'Reilly All rights reserved.
//

import Foundation
import Siesta
import CocoaLumberjackSwift

extension Resource {

    /**
     Add automatic retried to a resource, with the given owner object. Retries will stop if owner ceases to exist
     */
    func retryWith(owner: AnyObject) -> Self {

        self.addObserver(owner: owner) { resource, event in
            switch event {
            case .error:
                DDLogWarn("ResourceExtensions: Error retrieving resource \(self), retrying in 5")
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    resource.loadIfNeeded()
                }
                break

            default:
                break
            }
        }

        return self
    }
}
