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
    
    private let performOnMain: (@escaping () -> Void) -> Void

    public init(_ value: Value,
                performOnMain: @escaping (@escaping () -> Void) -> Void = { action in
                    DispatchQueue.main.async { action() }
                }) {
        self.value = value
        self.performOnMain = performOnMain
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
            performOnMain { observer.block(self.value) }
        }
    }
}
