public enum Direction: CaseIterable {
    case left
    case up
    case right
    case down
    
    public var opposite: Direction {
        switch self {
        case .left:
            Direction.right
        case .up:
            Direction.down
        case .right:
            Direction.left
        case .down:
            Direction.up
        }
    }
    
    public var offset: Coordinate {
        switch self {
        case .left:
            Coordinate(x: -1, y: 0)
        case .up:
            Coordinate(x: 0, y: -1)
        case .right:
            Coordinate(x: 1, y: 0)
        case .down:
            Coordinate(x: 0, y: 1)
        }
    }
}
