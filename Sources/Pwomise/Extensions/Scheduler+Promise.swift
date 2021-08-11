//
//  File.swift
//  
//
//  Created by Eric Rabil on 7/31/21.
//

import Foundation

public protocol _Scheduler {
    func schedule(_ block: @escaping () -> ())
    func wake()
}

extension DispatchQueue: _Scheduler {
    public func schedule(_ block: @escaping () -> ()) {
        async {
            block()
        }
    }
    
    public func wake() {
        
    }
}

extension RunLoop: _Scheduler {
    public func schedule(_ block: @escaping () -> ()) {
        CFRunLoopPerformBlock(getCFRunLoop(), CFRunLoopMode.defaultMode.rawValue, block)
    }
    
    public func wake() {
        CFRunLoopWakeUp(getCFRunLoop())
    }
}

public extension _Scheduler {
    func promise<Output>(_ cb: @escaping () throws -> Output) -> Promise<Output> {
        Promise { resolve, reject in
            self.schedule {
                do {
                    resolve(try cb())
                } catch {
                    reject(error)
                }
            }
            self.wake()
        }
    }
    
    func promise<R: PromiseConvertible>(_ cb: @escaping () throws -> R) -> Promise<R.Output> {
        Promise { resolve, reject in
            self.schedule {
                do {
                    try cb().asPromise.then(resolve).catch(reject)
                } catch {
                    reject(error)
                }
            }
            self.wake()
        }
    }
}
