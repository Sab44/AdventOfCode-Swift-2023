
public extension String {
    var lastIndex: String.Index {
        return index(before: endIndex)
    }
}

public extension Collection where Element: Numeric {
    func sum() -> Element {
        return reduce(0, +)
    }
}
