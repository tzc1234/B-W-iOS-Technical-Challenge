import Foundation

public final class Observable<Value> {
    struct Observer<V> {
        weak var observer: AnyObject?
        let block: (V) -> Void
    }

    private var observers = [Observer<Value>]()

    public var value: Value {
        didSet { notifyObservers() }
    }

    public init(_ value: Value) {
        self.value = value
    }

    public func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(value)
    }

    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }

    // Move all the dispatch queue concerns to Application, using DispatchOnMainQueueDecorator.
    // Other components need not to care about this.
    private func notifyObservers() {
        for observer in observers {
            observer.block(value)
        }
    }
}
