////  File.swift
//  
//
//  Created by Eric Rabil on 9/17/21.
//  
//

import Foundation

@available(macOS 10.12, *)
public extension Promise where Output == Void {
    convenience init(timeout: TimeInterval) {
        self.init { resolve in
            Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { timer in
                resolve(())
            }
        }
    }
}

@available(macOS 10.12, *)
public extension Promise {
    enum TimedResult {
        case finished(Output)
        case timedOut
    }
    
    func withLifetime(lifetime: TimeInterval) -> Promise<TimedResult> {
        Promise<Any>.any([
            OpaquePromise(self),
            OpaquePromise(Promise<Void>(timeout: lifetime))
        ]).then { result in
            switch result {
            case let output as Output:
                return .finished(output)
            default:
                return .timedOut
            }
        }
    }
}
