////  File.swift
//  
//
//  Created by Eric Rabil on 9/17/21.
//  
//

import Foundation

public class OpaquePromise: Promise<Any> {
    public init<T>(_ promise: Promise<T>) {
        super.init()
        
        promise.listeners.append { completion in
            self.result = .resolved(completion.map { $0 as Any })
        }
    }
}

public extension Promise {
    convenience init(_ promise: OpaquePromise) {
        self.init()
        
        promise.listeners.append { completion in
            self.result = .resolved(completion.flatMap { output in
                guard let output = output as? Output else {
                    return .failure(PromiseInconsistencyError.opaqueMismatch)
                }
                
                return .success(output)
            })
        }
    }
}
