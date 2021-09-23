//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public enum PendingPromise<Output, Failure: Error>: Equatable, CustomDebugStringConvertible {
    public static func == (lhs: PendingPromise<Output, Failure>, rhs: PendingPromise<Output, Failure>) -> Bool {
        switch lhs {
        case .pending:
            switch rhs {
            case .pending:
                return true
            default:
                return false
            }
        case .resolved:
            switch rhs {
            case .resolved:
                return true
            default:
                return false
            }
        }
    }
    
    case pending
    case resolved(Result<Output, Failure>)
    
    public var debugDescription: String {
        switch self {
        case .pending:
            return "pending"
        case .resolved(let result):
            switch result {
            case .failure(let error):
                return "rejected(\(error))"
            case .success(let output):
                return "resolved(\(output))"
            }
        }
    }
}
