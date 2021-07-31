//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public protocol _DictionaryConvertible {
    associatedtype Key: Hashable
    associatedtype Value
    associatedtype Dict = Dictionary<Key, Value>
    
    var asDictionary: Dictionary<Key, Value> { get }
}

extension Dictionary: _DictionaryConvertible {
    @_transparent
    public var asDictionary: Dictionary<Key, Value> { self }
}

public extension Promise where Output: _DictionaryConvertible {
    @inlinable
    var values: Promise<Dictionary<Output.Key, Output.Value>.Values> {
        then {
            $0.asDictionary.values
        }
    }
    
    @inlinable
    func compactMapValues<R>(_ cb: @escaping (Output.Value) throws -> R?) -> Promise<Dictionary<Output.Key, R>> {
        then {
            try $0.asDictionary.compactMapValues(cb)
        }
    }
}
