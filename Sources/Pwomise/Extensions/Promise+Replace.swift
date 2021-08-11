//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/11/21.
//

import Foundation

public extension Promise {
    func replace<NewOutput>(with newOutput: @autoclosure @escaping () -> NewOutput) -> Promise<NewOutput> {
        then { _ in
            newOutput()
        }
    }
}
