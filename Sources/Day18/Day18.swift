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
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
