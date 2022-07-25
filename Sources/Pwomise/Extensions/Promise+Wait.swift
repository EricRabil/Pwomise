//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/25/22.
//

import Foundation

public extension Promise {
    enum TimeoutError: Error { case timedOut }
    
    func wait(upTo time: DispatchTime) throws -> Output {
        var completion: Completion!
        let semaphore = DispatchSemaphore(value: 0)
        var semaphoreLocked: Bool {
            if semaphore.wait(timeout: .now()) == .success {
                semaphore.signal()
                return false
            }
            return true
        }
        always {
            completion = $0
            if semaphoreLocked {
                semaphore.signal()
            }
        }.resolving(on: DispatchQueue.global())
        if semaphore.wait(timeout: time) == .success {
            // finished in time, signal and return
            semaphore.signal()
        } else {
            // did not finish in time, throw
            throw TimeoutError.timedOut
        }
        return try completion.get()
    }
}
