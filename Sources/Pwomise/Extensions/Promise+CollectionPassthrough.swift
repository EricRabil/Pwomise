//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation
import Swexy

public extension Promise where Output: Collection {
    typealias Element = Output.Element
    
    @inlinable
    func compactMap<R>(_ cb: @escaping (Output.Element) throws -> R?) -> Promise<[R]> {
        then {
            try $0.compactMap(cb)
        }
    }
    
    @inlinable
    func flatMap<NewSequence: Sequence>(_ cb: @escaping (Output.Element) throws -> NewSequence) -> Promise<[NewSequence.Element]> {
        then {
            try $0.flatMap(cb)
        }
    }
    
    @inlinable
    func filter(_ cb: @escaping (Output.Element) throws -> Bool) -> Promise<[Output.Element]> {
        then {
            try $0.filter(cb)
        }
    }
    
    @inlinable
    func map<R>(_ cb: @escaping (Output.Element) throws -> R) -> Promise<[R]> {
        then {
            try $0.map(cb)
        }
    }
    
    @inlinable
    @discardableResult
    func forEach(_ cb: @escaping (Output.Element) throws -> Void) -> Promise<Void> {
        then {
            try $0.forEach(cb)
        }
    }
    
    @inlinable
    func dictionary<Key: Hashable>(keyedBy key: KeyPath<Element, Key>) -> Promise<[Key: Element]> {
        then {
            $0.dictionary(keyedBy: key)
        }
    }
    
    @inlinable
    func dictionary<Key: Hashable>(keyedBy key: KeyPath<Element, Optional<Key>>) -> Promise<[Key: Element]> {
        then {
            $0.dictionary(keyedBy: key)
        }
    }
    
    @inlinable
    func dictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Key>, valuedBy value: KeyPath<Element, Value>) -> Promise<[Key: Value]> {
        then {
            $0.dictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func dictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Optional<Key>>, valuedBy value: KeyPath<Element, Value>) -> Promise<[Key: Value]> {
        then {
            $0.dictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable>(keyedBy key: KeyPath<Element, Key>) -> Promise<[Key: [Element]]> {
        then {
            $0.collectedDictionary(keyedBy: key)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable>(keyedBy key: KeyPath<Element, Optional<Key>>) -> Promise<[Key: [Element]]> {
        then {
            $0.collectedDictionary(keyedBy: key)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Key>, valuedBy value: KeyPath<Element, Value>) -> Promise<[Key: [Value]]> {
        then {
            $0.collectedDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Optional<Key>>, valuedBy value: KeyPath<Element, Value>) -> Promise<[Key: [Value]]> {
        then {
            $0.collectedDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Key>, valuedBy value: KeyPath<Element, Optional<Value>>) -> Promise<[Key: [Value]]> {
        then {
            $0.collectedDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func collectedDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Optional<Key>>, valuedBy value: KeyPath<Element, Optional<Value>>) -> Promise<[Key: [Value]]> {
        then {
            $0.collectedDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func compactDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Key>, valuedBy value: KeyPath<Element, Optional<Value>>) -> Promise<[Key: Value]> {
        then {
            $0.compactDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func compactDictionary<Key: Hashable, Value>(keyedBy key: KeyPath<Element, Optional<Key>>, valuedBy value: KeyPath<Element, Optional<Value>>) -> Promise<[Key: Value]> {
        then {
            $0.compactDictionary(keyedBy: key, valuedBy: value)
        }
    }
    
    @inlinable
    func sorted(by areInIncreasingOrder: @escaping (Element, Element) throws -> Bool) -> Promise<[Element]> {
        then {
            try $0.sorted(by: areInIncreasingOrder)
        }
    }
    
    @inlinable
    func reduce<NewValue>(into createBase: @autoclosure @escaping () -> NewValue, using reduceBlock: @escaping (inout NewValue, Element) throws -> Void) -> Promise<NewValue> {
        then {
            try $0.reduce(into: createBase(), reduceBlock)
        }
    }
    
    @inlinable
    var first: Promise<Element?> {
        then {
            $0.first
        }
    }
    
    @inlinable
    func sorted<Value: Comparable>(usingKey key: KeyPath<Element, Value>, by areInIncreasingOrder: @escaping (Value, Value) throws -> Bool) -> Promise<[Element]> {
        then {
            try $0.sorted(usingKey: key, by: areInIncreasingOrder)
        }
    }
    
    @inlinable
    func sorted<Value: Comparable>(usingKey key: KeyPath<Element, Optional<Value>>, withDefaultValue defaultValue: @autoclosure @escaping () -> Value, by areInIncreasingOrder: @escaping (Value, Value) throws -> Bool) -> Promise<[Element]> {
        then {
            try $0.sorted(usingKey: key, withDefaultValue: defaultValue(), by: areInIncreasingOrder)
        }
    }
}

public extension Promise where Output: Collection, Output.Element: Collection {
    @inlinable
    func flatten() -> Promise<[Output.Element.Element]> {
        then {
            $0.flatten()
        }
    }
}
