//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/11/21.
//

import Foundation

public extension Collection {
    /// Serially spawns a promise for each element, resolving once all elements have succeeded.
    func serial<NewOutput>(_ generator: @escaping (Element) -> Promise<NewOutput>) -> Promise<[NewOutput]> {
        var promises = [Promise<NewOutput>]()
        var lastPromise: Promise<NewOutput>?
        
        for element in self {
            if let prev = lastPromise {
                lastPromise = prev.then { _ in
                    generator(element)
                }
                promises.append(lastPromise!)
            } else {
                lastPromise = generator(element)
                promises.append(lastPromise!)
            }
        }
        
        return Promise.all(promises)
    }
}
