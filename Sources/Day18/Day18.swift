//
//  Day18.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct DigInstruction: Parsable {
    let direction: Direction
    let meters: Int
    let color: String
    
    static func parse(raw: String) throws -> DigInstruction {
        var direction = Direction.left
        switch raw.split(separator: " ")[0] {
        case "U":
            direction = .up
        case "R":
            direction = .right
        case "D":
            direction = .down
        default:
            direction = .left
        }
        
        let meters = Int(raw.split(separator: " ")[1])!
        let color = raw.split(separator: " ")[2].dropFirst(2).dropLast(1)
        
        return DigInstruction(direction: direction, meters: meters, color: String(color))
    }
}

@main
struct Day18: Puzzle {
    typealias Input = [DigInstruction]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day18 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let start = Coordinate.zero
        var trench = [start]
        
        for instruction in input {
            for _ in 1...instruction.meters {
                let current = trench.last!
                trench.append(current.moved(to: instruction.direction))
            }
        }
        
        let minY = trench.map { $0.y }.min()!
        let minX = trench.map { $0.x }.min()!
        
        let yOffset = minY < 0 ? -minY : 0
        let xOffset = minX < 0 ? -minX : 0
        
        trench = trench.map { Coordinate(x: $0.x + xOffset, y: $0.y + yOffset) }
        
        let maxY = trench.map { $0.y }.max()!
        let maxX = trench.map { $0.x }.max()!
        
        var visualized: [[Character]] = Array(repeating: Array(repeating: ".", count: maxX + 1), count: maxY + 1)
        for coordinate in trench {
            visualized[coordinate.y][coordinate.x] = "#"
        }
        
        // flood fill approach
        visualized.insert(Array(repeating: ".", count: maxX + 1), at: 0)
        visualized.append(Array(repeating: ".", count: maxX + 1))
        
        visualized = visualized.map { $0.inserted(newElement: ".", at: 0) }.map { $0.plus(".") }
        
        let floodStart = Coordinate.zero
        var floodStack = Stack<Coordinate>()
        floodStack.push(floodStart)
        
        var flooded = Set<Coordinate>()
        
        while !floodStack.isEmpty {
            let current = floodStack.pop()!
            flooded.insert(current)
            
            let emptyNeighbors = current.neighbors().filter {
                visualized.indices.contains($0.y) && visualized[0].indices.contains($0.x)
            }.filter {
                visualized[$0.y][$0.x] == "."
            }
            
            for empty in emptyNeighbors {
                if !flooded.contains(empty) {
                    floodStack.push(empty)
                }
            }
        }
        
        return (visualized.count * visualized[0].count) - flooded.count
    }
}

// MARK: - PART 2

extension Day18 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let updatedInstructions = input.map {
            let meters = Int(String($0.color.prefix(5)), radix: 16)!
            var newDirection = Direction.left
            switch $0.color.suffix(1) {
            case "0":
                newDirection = .right
            case "1":
                newDirection = .down
            case "2":
                newDirection = .left
            default:
                newDirection = .up
            }

            return DigInstruction(direction: newDirection, meters: meters, color: "")
        }
        
        let start = Coordinate.zero
        var trench = [start]
        var perimeter = 0
        
        for instruction in updatedInstructions {
            let current = trench.last!
            let next = current.moved(to: instruction.direction, steps: instruction.meters)
            trench.append(next)
            
            perimeter += instruction.meters
        }
        
        if trench.contains(where: { $0.y < 0 || $0.x < 0 }) {
            let minY = trench.min { $0.y < $1.y }!.y
            let minX = trench.min { $0.x < $1.x }!.x
            
            trench = trench.map { Coordinate(x: $0.x - minX, y: $0.y - minY) }
        }

        // Shoelace formula
        // due to the definition of the puzzle, all points are already ordered
        var result = 0
        for index in trench.indices {
            if index == trench.indices.lastIndex {
                continue
            }
            
            result += (trench[index].y + trench[index + 1].y) * (trench[index].x - trench[index + 1].x)
        }
        result = (result / 2)
        
        // How does the thick line of the trench contribute to overall area
        // available for lava? Consider that the infinitesimal point in space
        // that defines the origin is the point in the exact center of the
        // first 1x1 cube dug. The area, as calculated, is thus bound by an
        // infinitely thin line running through the center of the trench cubes.
        // This means that, for your average side section of the trench, half that
        // trench cube is in the area and half of it is outside and needs to be
        // added back in. The exception here are corner trench cubes. For the four
        // corners, 3/4 of that cube is outside the bounded region. This means an
        // extra 1/4 of a trench cube for each, and for four corners... It's an
        // extra "+ 1". The inner corners (those bends and twists in the walls)
        // don't matter because for every cube 3/4 inside the bounded area, there's
        // a corresponding cube with only 1/4 inside the bounded area.
        result += (perimeter / 2) + 1
        
        return result
    }

}
