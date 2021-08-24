//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/24/21.
//

#if canImport(Combine)

import Foundation
import Swexy

@available(macOS 10.15, iOS 13.0, *)
public extension SubjectStream {
    @discardableResult
    func oncePromise(where valid: @escaping (Element) -> Bool) -> Promise<Element> {
        return Promise { resolve in
            self.once(where: valid, resolve)
        }
    }
}

#endif
