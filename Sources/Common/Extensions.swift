
public extension String {
    var lastIndex: String.Index {
        return index(before: endIndex)
    }
}

public extension Array {
    var lastIndex: Int {
        return endIndex - 1
    }
    
    func getOrNil(index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    func plus(_ element: Element) -> Array<Element> {
        var copy = self
        copy.append(element)
        return copy
    }
    
    func inserted(newElement: Element, at: Int) -> Array<Element> {
        if at >= 0 && at <= endIndex {
            var copy = self
            copy.insert(newElement, at: at)
            return copy
        }
        return self
    }
}

public extension Set {
    func plus(_ element: Element) -> Set<Element> {
        var copy = self
        copy.insert(element)
        return copy
    }
}

public extension Range<Int> {
    var lastIndex: Int {
        return count - 1
    }
}

public extension Collection where Element: Numeric {
    func sum() -> Element {
        return reduce(0, +)
    }
}

/*
 Returns the Greatest Common Divisor of two numbers.
 */
public func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)
    
    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

/*
 Returns the least common multiple of two numbers.
 */
public func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}
