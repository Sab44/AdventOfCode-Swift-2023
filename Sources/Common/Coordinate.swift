import Foundation

public struct Coordinate: Hashable {
    public let x: Int
    public let y: Int
    
    public static let zero = Coordinate(x: 0, y: 0)
    
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    // manhattan distance
    @inlinable
    public func distance(to point: Coordinate) -> Int {
        abs(x - point.x) + abs(y - point.y)
    }
    
    @inlinable
    public static func + (_ lhs: Coordinate, _ rhs: Coordinate) -> Coordinate {
        Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    @inlinable
    public static func - (_ lhs: Coordinate, _ rhs: Coordinate) -> Coordinate {
        Coordinate(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    @inlinable
    public static func * (_ lhs: Coordinate, _ rhs: Int) -> Coordinate {
        Coordinate(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

// MARK: - neighbors
public extension Coordinate {
    func neighbors() -> [Coordinate] {
        return Direction.allCases.map { self + $0.offset }
    }
    
    @inlinable
    func moved(to direction: Direction, steps: Int = 1) -> Coordinate {
        self + direction.offset * steps
    }
}
