import Foundation
import Swog

public protocol PromiseConvertible {
    associatedtype Output
    
    @inlinable
    var asPromise: Promise<Output> { get }
}

public enum PromiseInconsistencyError: Error {
    case emptyArray
    case opaqueMismatch
}

public protocol PromiseAbuseDelegate {
    func promise<T>(_ promise: Promise<T>, doubleResolvedWithResult result: PendingPromise<T, Error>, resolutionStackTrace: [String], abusingStackTrace: [String])
}

private let abuseLog = Logger(category: "Abuse", subsystem: "com.ericrabil.pwomise")
public var SharedPromiseAbuseDelegate: PromiseAbuseDelegate?

typealias dispatch_get_current_queue_t = @convention(c) () -> Unmanaged<DispatchQueue>
private let dispatch_get_current_queue = dlsym(dlopen(nil, RTLD_GLOBAL), "dispatch_get_current_queue").map {
    unsafeBitCast($0, to: dispatch_get_current_queue_t.self)
}

public struct PromiseRuntime {
    /// Enable this when debugging double-resolve errors to locate the first resolver
    public static var recordResolutionStackTrace = false
}
public class Promise<Output>: CustomDebugStringConvertible {
    internal typealias Pending = PendingPromise<Output, Error>
    public typealias Completion = Result<Output, Error>
    public typealias Resolve = (Output) -> ()
    public typealias Reject = (Error) -> ()
    
    public static func any(_ promises: [Promise<Output>]) -> Promise<Output> {
        guard promises.count > 0 else {
            return .failure(PromiseInconsistencyError.emptyArray)
        }
        
        let superPromise = Promise()
        
        for promise in promises {
            promise.always { completion in
                guard superPromise.pending else {
                    return
                }
                
                superPromise.result = .resolved(completion)
            }
        }
        
        return superPromise
    }
    
    public static func all(_ promises: [Promise<Output>]) -> Promise<[Output]> {
        guard promises.count > 0 else {
            return .success([])
        }
        
        let superPromise = Promise<[Output]>()
        
        var outputs = [Output]() {
            didSet {
                guard superPromise.pending else {
                    outputs = []
                    return
                }
                
                if outputs.count == promises.count {
                    superPromise.result = .resolved(.success(outputs))
                }
            }
        }
        
        promises.forEach { subPromise in
            subPromise.always { completion in
                switch completion {
                case .success(let output):
                    outputs.append(output)
                case .failure(let error):
                    guard superPromise.pending else {
                        return
                    }
                    
                    superPromise.result = .resolved(.failure(error))
                }
            }
        }
        
        return superPromise
    }
    
    public var resolveQueue: _Scheduler = DispatchQueue.main
    
    private var resolutionStackTrace: [String] = []
    
    /// The underlying status of the promise
    internal var result: Pending = .pending {
        didSet {
            // We resolved!! Tell the listeners
            emit()
        }
        willSet {
            guard result == .pending, newValue != .pending else {
                /// Result can only be set once – its a promise of a result, not a publisher
                let resolutionStackTrace = resolutionStackTrace, callStackSymbols = Thread.callStackSymbols
                abuseLog.fault("Double-completion of \(String(describing: type(of: self))) \n- original stack trace: \n\(resolutionStackTrace.joined(separator: "\n"))\n- violating stack trace: \(callStackSymbols)")
                if let abuseDelegate = SharedPromiseAbuseDelegate {
                    abuseDelegate.promise(self, doubleResolvedWithResult: newValue, resolutionStackTrace: resolutionStackTrace, abusingStackTrace: Thread.callStackSymbols)
                } else {
                    print(resolutionStackTrace.joined(separator: "\n"))
                    preconditionFailure("result is omnidirectional, from pending to resolved.")
                }
                
                return
            }
            
            if PromiseRuntime.recordResolutionStackTrace {
                resolutionStackTrace = Thread.callStackSymbols
            }
        }
    }
    
    typealias Listener = (Completion) -> ()
    
    internal var listeners: [Listener] = [] {
        didSet {
            guard listeners.count > 0 else {
                return
            }
            
            // Whenever a listener is added, try to resolve
            emit()
        }
    }
    
    public init(_ cb: (@escaping Resolve, @escaping Reject) -> ()) {
        cb({ output in
            self.result = .resolved(.success(output))
        }, { error in
            self.result = .resolved(.failure(error))
        })
    }
    
    public init(_ cb: (@escaping Resolve) -> ()) {
        cb({ output in
            self.result = .resolved(.success(output))
        })
    }
    
    public init(catching cb: @escaping () throws -> Output) {
        do {
            result = .resolved(.success(try cb()))
        } catch {
            result = .resolved(.failure(error))
        }
    }
    
    public init(result: Completion) {
        self.result = .resolved(result)
    }
    
    internal init() {}
    
    public var pending: Bool {
        result == .pending
    }
    
    public var resolved: Bool {
        result != .pending
    }
    
    private func createExecutorFunction(_ result: Completion) -> ((@escaping Listener) -> ())? {
        switch resolveQueue {
        case is OS_dispatch_queue_concurrent:
            // this should be scheduled concurrently, it must have an executor
            break
        case let queue as DispatchQueue:
            if dispatch_get_current_queue?().takeUnretainedValue() == queue {
                // same queue, passthrough
                return nil
            }
        case let runLoop as RunLoop:
            if RunLoop.current == runLoop {
                // same runloop, passthrough
                return nil
            }
        default:
            break
        }
        return { listener in
            self.resolveQueue.schedule {
                listener(result)
            }
        }
    }
    
    private func emit() {
        guard case .resolved(let result) = result, listeners.count > 0 else {
            // Not resolved or no listeners
            return
        }
        
        // Pass the result to the listeners
        let listeners = listeners
        self.listeners = []
        
        if let executor = createExecutorFunction(result) {
            listeners.forEach(executor)
            resolveQueue.wake()
        } else {
            listeners.forEach { $0(result) }
        }
    }
    
    // Changes the RunLoop downstream listeners are invoked on
    @discardableResult
    public func resolve(on queue: _Scheduler) -> Promise<Output> {
        let newPromise = Promise()
        newPromise.resolveQueue = queue
        
        listeners.append { result in
            newPromise.result = .resolved(result)
        }
        
        return newPromise
    }
    
    // Changes the RunLoop downstream listeners are invoked on
    @discardableResult
    public func resolving(on queue: _Scheduler) -> Promise<Output> {
        resolveQueue = queue
        
        return self
    }
    
    // Invoked when the promise resolves, receiving the result and returning a downstream promise representing the return value
    @discardableResult
    public func always<R>(_ cb: @escaping (Completion) throws -> R) -> Promise<R> {
        let promise = Promise<R>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                promise.result = .resolved(.success(try cb(result)))
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise resolves, receiving the result and returning a downstream promise representing the return value
    @discardableResult
    public func always<R: PromiseConvertible>(_ cb: @escaping (Completion) throws -> R) -> Promise<R.Output> {
        let promise = Promise<R.Output>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                try cb(result).asPromise.always { result in
                    promise.result = .resolved(result)
                }
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise succeeds, receiving the output and returning a downstream promise representing the return value
    @discardableResult
    public func then<R: PromiseConvertible>(_ cb: @escaping (Output) throws -> R) -> Promise<R.Output> {
        let promise = Promise<R.Output>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                switch result {
                case .success(let output):
                    try cb(output).asPromise.always { result in
                        promise.result = .resolved(result)
                    }
                case .failure(let error):
                    throw error
                }
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise succeeds, receiving the output and returning a downstream promise representing the return value
    @discardableResult
    public func then<R>(_ cb: @escaping (Output) throws -> R) -> Promise<R> {
        let promise = Promise<R>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                switch result {
                case .success(let output):
                    promise.result = .resolved(.success(try cb(output)))
                case .failure(let error):
                    throw error
                }
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise rejects, receiving the error and returning a downstream promise representing the return value
    @discardableResult
    public func `catch`<R: PromiseConvertible>(_ cb: @escaping (Error) throws -> R) -> Promise<R.Output> where R.Output == Output {
        let promise = Promise<Output>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                switch result {
                case .success:
                    promise.result = .resolved(result)
                case .failure(let error):
                    try cb(error).asPromise.always { result in
                        promise.result = .resolved(result)
                    }
                }
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise rejects, receiving the error and returning a downstream promise representing the return value
    @discardableResult
    public func `catch`(_ cb: @escaping (Error) throws -> Output) -> Promise<Output> {
        let promise = Promise<Output>()
        promise.resolveQueue = resolveQueue
        
        listeners.append { result in
            do {
                switch result {
                case .success:
                    promise.result = .resolved(result)
                case .failure(let error):
                    promise.result = .resolved(.success(try cb(error)))
                }
            } catch {
                promise.result = .resolved(.failure(error))
            }
        }
        
        return promise
    }
    
    // Invoked when the promise rejects, as an observer. It cannot recover the promise.
    @discardableResult
    public func onRejection(_ cb: @escaping (Error) -> Void) -> Self {
        listeners.append { result in
            switch result {
            case .failure(let error):
                cb(error)
            default:
                return
            }
        }
        return self
    }
    
    public var debugDescription: String {
        "Promise<\(Output.self)> { \(result.debugDescription) }"
    }
}
