//
//  Day23.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct State: Hashable {
    let position: Coordinate
    let steps: Int
    let path: Set<Coordinate>
    
    init(position: Coordinate, steps: Int = 0, path: Set<Coordinate> = []) {
        self.position = position
        self.steps = steps
        self.path = path
    }
}

@main
struct Day23: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day23 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var stack = Stack<State>()
        
        let start = Coordinate(x: 1, y: 0)
        let end = Coordinate(x: input[0].lastIndex - 1, y: input.lastIndex)
        
        let initialState = State(position: start, path: [start])
        stack.push(initialState)
        
        var longestPath = 0
        
        let validY = 0...input.lastIndex
        let validX = 0...input[0].lastIndex
        
        while !stack.isEmpty {
            let current = stack.pop()!
            
            if current.position == end {
                if current.steps > longestPath {
                    longestPath = current.steps
                }
                continue
            }
            
            let neighbors = validNeighbors(position: current.position, input: input).filter {
                !current.path.contains($0) && validY.contains($0.y) && validX.contains($0.x) && input[$0.y][$0.x] != "#"
            }.map {
                State(position: $0, steps: current.steps + 1, path: current.path.plus($0))
            }
            
            for neighbor in neighbors {
                stack.push(neighbor)
            }
        }
        
        return longestPath
    }
    
    static func validNeighbors(position: Coordinate, input: Input) -> [Coordinate] {
        switch input[position.y][position.x] {
        case "^":
            return [position.moved(to: .up)]
        case ">":
            return [position.moved(to: .right)]
        case "<":
            return [position.moved(to: .left)]
        case "v":
            return [position.moved(to: .down)]
        default:
            break
        }
        return Direction.allCases.map { position + $0.offset }
    }
}

// MARK: - PART 2

extension Day23 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
