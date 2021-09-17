////  File.swift
//  
//
//  Created by Eric Rabil on 9/17/21.
//  
//

import Foundation
import Combine

@available(macOS 10.15, *)
public extension Promise {
    var publisher: Future<Output, Error> {
        Future { resolve in
            let _ = self.observeAlways(resolve)
        }
    }
}
