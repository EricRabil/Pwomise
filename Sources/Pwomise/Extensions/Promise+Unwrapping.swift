//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public protocol _OptionalConvertible {
    associatedtype Element
    @inlinable
    var asOptional: Optional<Element> { get }
}

extension Optional: _OptionalConvertible {
    @_transparent
    public var asOptional: Optional<Wrapped> { return self }
}

extension Promise: PromiseConvertible {
    @_transparent
    public var asPromise: Promise<Output> {
        self
    }
}

extension Promise where Output: _OptionalConvertible {
    public func assert(_ error: @autoclosure @escaping () -> Error) -> Promise<Output.Element> {
        then { output in
            guard let output = output.asOptional else {
                throw error()
            }
            
            return output
        }
    }
}

extension Promise where Output: Equatable {
    public func expect(_ value: Output, failure: @autoclosure @escaping () -> Error) -> Promise<Output> {
        then { output in
            guard output == value else {
                throw failure()
            }
            
            return output
        }
    }
}
