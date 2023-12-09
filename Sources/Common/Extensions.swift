
public extension String {
    var lastIndex: String.Index {
        return index(before: endIndex)
    }
}

public extension Array {
    var lastIndex: Int {
        return endIndex - 1
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
