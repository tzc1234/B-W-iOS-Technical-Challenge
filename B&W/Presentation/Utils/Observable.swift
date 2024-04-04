import Foundation

public typealias PerformOnMainQueue = (@escaping () -> Void) -> Void

public final class Observable<Value> {

    struct Observer<V> {
        weak var observer: AnyObject?
        let block: (V) -> Void
    }

    private var observers = [Observer<Value>]()

    public var value: Value {
        didSet { notifyObservers() }
    }
    
    private let performOnMainQueue: PerformOnMainQueue

    public init(_ value: Value,
                // Add default param for performOnMainQueue, enable testability.
                // Code inside DispatchQueue.main.async is hard to test.
                performOnMainQueue: @escaping PerformOnMainQueue = { action in
                    DispatchQueue.main.async { action() }
                }) {
        self.value = value
        self.performOnMainQueue = performOnMainQueue
    }

    public func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(self.value)
    }

    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }

    private func notifyObservers() {
        for observer in observers {
            performOnMainQueue { observer.block(self.value) }
        }
    }
}
