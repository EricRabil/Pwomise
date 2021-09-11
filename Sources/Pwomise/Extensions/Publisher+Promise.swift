//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/11/21.
//

import Foundation
#if canImport(Combine)
import Combine

/// Naive? probably.
@available(macOS 10.15, iOS 13.0, *)
private var cancellables = Set<AnyCancellable>()

@available(macOS 10.15, iOS 13.0, *)
public extension Publisher {
    var promise: Promise<Output> {
        let promise = Promise<Output>()
        
        var cancellable: AnyCancellable?
        
        cancellable = sink(receiveCompletion: {
            switch $0 {
            case .failure(let err):
                promise.result = .resolved(.failure(err))
                cancellable?.cancel()
                cancellable = nil
            default:
                break
            }
        }, receiveValue: { value in
            promise.result = .resolved(.success(value))
            cancellable?.cancel()
            cancellable = nil
        })
        
        return promise
    }
}

#endif
