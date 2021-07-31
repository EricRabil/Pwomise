//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public extension Promise {
    
    
    static func success(_ output: Output) -> Promise<Output> {
        .completed(.success(output))
    }
    
    static func failure(_ error: Error) -> Promise<Output> {
        .completed(.failure(error))
    }
    
    static func completed<Output>(_ result: Promise<Output>.Completion) -> Promise<Output> {
        Promise<Output>(result: result)
    }
}
