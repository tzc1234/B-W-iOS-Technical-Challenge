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
        observerBlock(self.value)
    }

    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }

    private func notifyObservers() {
        for observer in observers {
            DispatchQueue.main.async { observer.block(self.value) }
        }
    }
}
