//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/11/21.
//

import Foundation
import Combine

/// Naive? probably.
@available(macOS 10.15, *)
private var cancellables = Set<AnyCancellable>()

@available(macOS 10.15, *)
public extension Publisher {
    var promise: Promise<Output> {
        let promise = Promise<Output>()
        
        sink(receiveCompletion: {
            switch $0 {
            case .failure(let err):
                promise.result = .resolved(.failure(err))
            default:
                break
            }
        }, receiveValue: { value in
            promise.result = .resolved(.success(value))
        }).store(in: &cancellables)
        
        return promise
    }
}
