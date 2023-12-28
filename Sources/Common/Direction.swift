public enum Direction: CaseIterable {
    case left
    case up
    case right
    case down
    
    // improve this with Swift 5.9
    // https://www.hackingwithswift.com/swift/5.9/if-switch-expressions
    public var opposite: Direction {
        var oppositeDirection: Direction = Direction.up
        switch self {
        case .left:
            oppositeDirection = Direction.right
        case .up:
            oppositeDirection = Direction.down
        case .right:
            oppositeDirection = Direction.left
        case .down:
            oppositeDirection = Direction.up
        }
        return oppositeDirection
    }
    
    public var offset: Coordinate {
        var directionOffset = Coordinate(x: 0, y: 0)
        switch self {
        case .left:
            directionOffset = Coordinate(x: -1, y: 0)
        case .up:
            directionOffset = Coordinate(x: 0, y: -1)
        case .right:
            directionOffset = Coordinate(x: 1, y: 0)
        case .down:
            directionOffset = Coordinate(x: 0, y: 1)
        }
        return directionOffset
    }
}
