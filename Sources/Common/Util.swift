// Packages require at least one swift file to prevent errors
// This file is there for it
// Feel free to add any code you wanna share accross multiple days

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
