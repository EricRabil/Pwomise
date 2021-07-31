//
//  Promise+Optional.swift
//
//  Created by Eric Rabil on 7/30/21.
//  Copyright © 2021 Eric Rabil. All rights reserved.
//

import Foundation

public extension Promise where Output: Collection, Output.Element: _OptionalConvertible {
    @inlinable
    var nonnull: Promise<[Output.Element.Element]> {
        compactMap { $0.asOptional }
    }
}

public extension Promise where Output: _OptionalConvertible {
    @inlinable
    func maybeMap<R>(_ cb: @escaping (Output.Element) throws -> R) -> Promise<R?> {
        then {
            guard let value = $0.asOptional else {
                return nil
            }
            
            return try cb(value)
        }
    }
    
    @inlinable
    func maybeMap<R>(_ cb: @escaping (Output.Element) throws -> R) -> Promise<R.Element?> where R: _OptionalConvertible {
        then { value in
            guard let value = value.asOptional else {
                return nil
            }
            
            return try cb(value).asOptional
        }
    }
    
    @inlinable
    func maybeMap<R: PromiseConvertible>(_ cb: @escaping (Output.Element) throws -> R) -> Promise<R.Output?> {
        then { value -> Promise<R.Output?> in
            guard let value = value.asOptional else {
                return Promise<R.Output?>.success(nil)
            }
            
            return try cb(value).asPromise.then { $0 as R.Output? }
        }
    }
    
    @inlinable
    func maybeMap<R: PromiseConvertible>(_ cb: @escaping (Output.Element) throws -> R) -> Promise<R.Output.Element?> where R.Output: _OptionalConvertible {
        then { value -> Promise<R.Output.Element?> in
            guard let value = value.asOptional else {
                return .success(nil)
            }
            
            return try cb(value).asPromise.then { $0.asOptional }
        }
    }
}
