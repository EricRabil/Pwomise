//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public extension Promise {
    func observeOutput(_ cb: @escaping (Output) -> Void) -> Promise<Output> {
        then { output in
            cb(output)
            return output
        }
    }
    
    func observeFailure(_ cb: @escaping (Error) -> Void) -> Promise<Output> {
        `catch` { error in
            cb(error)
            throw error
        }
    }
    
    func observeAlways(_ cb: @escaping (Completion) -> Void) -> Promise<Output> {
        always { result -> Promise<Output> in
            cb(result)
            return Promise.completed(result)
        }
    }
}
