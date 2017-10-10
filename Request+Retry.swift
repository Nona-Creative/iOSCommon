//
//  Request+Retry.swift
//  orderin
//
//  Created by David O'Reilly on 2017/01/25.
//  Copyright © 2017 Breakdesign. All rights reserved.
//

import Foundation
import Siesta
import CocoaLumberjackSwift

extension Request {
    /**
     Add a success and failure callback to the request and cause it to retry on network (not server) errors.

     The success and failure callbacks will still be called in the same way, except that network failures cause a transparent retry after a delay
     */
    @discardableResult
    func retryOnNetworkErrors(withOnSuccess successCallback: @escaping (Entity<Any>) -> Void, onFailure failureCallback: ((RequestError) -> Void)? = nil) -> Self {
        onSuccess(successCallback)
        func failureRetryCallback(error: RequestError) {
            if error.httpStatusCode == nil {
                DDLogWarn("RequestExtensions: Failed with network error, retrying in 5...")
                let newRequest = repeated().onSuccess(successCallback).onFailure(failureRetryCallback)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    newRequest.start()
                }
            } else {
                failureCallback?(error)
            }
        }
        onFailure(failureRetryCallback)
        return self
    }
}
