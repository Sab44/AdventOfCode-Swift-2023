public protocol Stackable {
    associatedtype Element
    func peek() -> Element?
    mutating func push(_ element: Element)
    @discardableResult mutating func pop() -> Element?
    func elementCount() -> Int
}

public extension Stackable {
    var isEmpty: Bool { peek() == nil }
}

public struct Stack<Element>: Stackable where Element: Equatable {
    private var storage = [Element]()
    public func peek() -> Element? { storage.last }
    public mutating func push(_ element: Element) { storage.append(element)  }
    public mutating func pop() -> Element? { storage.popLast() }
    public func elementCount() -> Int { storage.count }
}

extension Stack: Equatable {
    public static func == (lhs: Stack<Element>, rhs: Stack<Element>) -> Bool { lhs.storage == rhs.storage }
}

extension Stack: CustomStringConvertible {
    public var description: String { "\(storage)" }
}
    
extension Stack: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Self.Element...) { storage = elements }
}
