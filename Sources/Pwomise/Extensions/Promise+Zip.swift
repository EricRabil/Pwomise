//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public extension Promise {
    func zip<OtherOutput, OtherPromise: Promise<OtherOutput>>(_ cb: @escaping (Output) -> OtherPromise) -> Promise<(Output, OtherPromise.Output)> {
        then { result in
            cb(result).asPromise.then { otherResult in
                (result, otherResult)
            }
        }
    }
}
