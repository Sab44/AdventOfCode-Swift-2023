//
//  Day10.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Pipe {
    let position: Coordinate
    let direction: Direction
}

let leftPipes: [(Character, Direction)] = [("-", .left), ("L", .up) , ("F", .down)]
let topPipes: [(Character, Direction)] = [("|", .up), ("7", .left) , ("F", .right)]
let rightPipes: [(Character, Direction)] = [("-", .right), ("J", .up) , ("7", .down)]
let bottomPipes: [(Character, Direction)] = [("|", .down), ("L", .right) , ("J", .left)]

@main
struct Day10: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day10 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let startY = input.firstIndex { $0.contains("S") }!
        let startX = input[startY].firstIndex(of: "S")!
        
        var startPipes: [Pipe] = []
        
        if let left = input[startY].getOrNil(index: startX - 1),
           let direction = leftPipes.first(where: { $0.0 == left })?.1 {
            startPipes.append(Pipe(position: Coordinate(x: startX - 1, y: startY), direction: direction))
        }
        
        if let top = input.getOrNil(index: startY - 1)?.getOrNil(index: startX),
           let direction = topPipes.first(where: { $0.0 == top })?.1 {
            startPipes.append(Pipe(position: Coordinate(x: startX, y: startY - 1), direction: direction))
        }
        
        if let right = input[startY].getOrNil(index: startX + 1),
           let direction = rightPipes.first(where: { $0.0 == right })?.1 {
            startPipes.append(Pipe(position: Coordinate(x: startX + 1, y: startY), direction: direction))
        }
        
        if let bottom = input.getOrNil(index: startY + 1)?.getOrNil(index: startX),
           let direction = bottomPipes.first(where: { $0.0 == bottom })?.1 {
            startPipes.append(Pipe(position: Coordinate(x: startX, y: startY + 1), direction: direction))
        }
        
        if startPipes.count != 2 {
            throw ExecutionError.unsolvable
        }
        
        var pipe1Path = [startPipes[0]]
        var pipe2Path = [startPipes[1]]
        var nextPipe1: Pipe = startPipes[0]
        var nextPipe2: Pipe = startPipes[1]
        
        while nextPipe1.position != nextPipe2.position {
            nextPipe1 = getNextPipe(input: input, currentPipe: nextPipe1)
            nextPipe2 = getNextPipe(input: input, currentPipe: nextPipe2)
            
            pipe1Path.append(nextPipe1)
            pipe2Path.append(nextPipe2)
        }
        
        return pipe1Path.count
    }
}

extension Day10 {
    private static func getNextPipe(input: Input, currentPipe: Pipe) -> Pipe {
        switch currentPipe.direction {
        case .left:
            let newPipe = input[currentPipe.position.y][currentPipe.position.x - 1]
            return Pipe(position: Coordinate(x: currentPipe.position.x - 1, y: currentPipe.position.y), direction: leftPipes.first { $0.0 == newPipe }?.1 ?? .left)
        case .up:
            let newPipe = input[currentPipe.position.y - 1][currentPipe.position.x]
            return Pipe(position: Coordinate(x: currentPipe.position.x, y: currentPipe.position.y - 1), direction: topPipes.first { $0.0 == newPipe }?.1 ?? .up)
        case .right:
            let newPipe = input[currentPipe.position.y][currentPipe.position.x + 1]
            return Pipe(position: Coordinate(x: currentPipe.position.x + 1, y: currentPipe.position.y), direction: rightPipes.first { $0.0 == newPipe }?.1 ?? .right)
        default:
            let newPipe = input[currentPipe.position.y + 1][currentPipe.position.x]
            return Pipe(position: Coordinate(x: currentPipe.position.x, y: currentPipe.position.y + 1), direction: bottomPipes.first { $0.0 == newPipe }?.1 ?? .down)
        }
    }
}

// MARK: - PART 2

extension Day10 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let startY = input.firstIndex { $0.contains("S") }!
        let startX = input[startY].firstIndex(of: "S")!
        
        var startPipe: Pipe? = nil
        
        if let left = input[startY].getOrNil(index: startX - 1),
           let direction = leftPipes.first(where: { $0.0 == left })?.1 {
            startPipe = Pipe(position: Coordinate(x: startX - 1, y: startY), direction: direction)
        } else if let top = input.getOrNil(index: startY - 1)?.getOrNil(index: startX),
           let direction = topPipes.first(where: { $0.0 == top })?.1 {
            startPipe = Pipe(position: Coordinate(x: startX, y: startY - 1), direction: direction)
        } else if let right = input[startY].getOrNil(index: startX + 1),
           let direction = rightPipes.first(where: { $0.0 == right })?.1 {
            startPipe = Pipe(position: Coordinate(x: startX + 1, y: startY), direction: direction)
        }
        
        var pipePath = [startPipe!]
        
        while pipePath.count == 1 || pipePath.last!.position != Coordinate(x: startX, y: startY) {
            let nextPipe = getNextPipe(input: input, currentPipe: pipePath.last!)
            
            pipePath.append(nextPipe)
        }
        let pipePos = pipePath.map { $0.position }
        let pipePosSet = Set(pipePos)
        
        var allCoordinates = Set<Coordinate>()
        for i in input.indices {
            for j in input[0].indices {
                allCoordinates.insert(Coordinate(x: j, y: i))
            }
        }
        allCoordinates.subtract(pipePosSet)
        
        return allCoordinates.filter { $0.isInShape(polygon: pipePos)}.count
    }
}

private extension Coordinate {
    // even-odd rule algorithm
    func isInShape(polygon: [Coordinate], countIfOnBoundary: Bool = false) -> Bool {
        var j = polygon.count - 1
        var isInShape = false
        
        for i in polygon.indices {
            if (self.x == polygon[i].x) && (self.y == polygon[i].y) {
                // point is a corner
                return countIfOnBoundary
            }
            
            if (polygon[i].y > self.y) != (polygon[j].y > self.y) {
                let slope = (self.x - polygon[i].x) * (polygon[j].y - polygon[i].y) - (polygon[j].x - polygon[i].x) * (self.y - polygon[i].y)
                if slope == 0 {
                    // point is on boundary
                    return countIfOnBoundary
                }
                if (slope < 0) != (polygon[j].y < polygon[i].y) {
                    isInShape = !isInShape
                }
            }
            j = i
        }
        
        return isInShape
    }
}
