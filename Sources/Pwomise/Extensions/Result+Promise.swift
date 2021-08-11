//
//  File.swift
//  
//
//  Created by Eric Rabil on 8/11/21.
//

import Foundation

public extension Result {
    var promise: Promise<Success> {
        switch self {
        case .success(let output):
            return .success(output)
        case .failure(let error):
            return .failure(error)
        }
    }
}
