//
//  Day23.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common
import Collections

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
        return traverse(input: input) { current in
            return validNeighbors(position: current.position, input: input).filter {
                !current.path.contains($0) && input.indices.contains($0.y) && input[0].indices.contains($0.x) && input[$0.y][$0.x] != "#"
            }.map { ($0, 1) }
        }
    }
    
    private static func validNeighbors(position: Coordinate, input: Input) -> [Coordinate] {
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
    
    private static func traverse(input: Input, getNeighbors: (State) -> [(Coordinate, Int)]) -> Int {
        var stack = Stack<State>()
        
        let start = Coordinate(x: 1, y: 0)
        let end = Coordinate(x: input[0].lastIndex - 1, y: input.lastIndex)
        
        let initialState = State(position: start, path: [start])
        stack.push(initialState)
        
        var longestPath = 0
        
        while !stack.isEmpty {
            let current = stack.pop()!
            
            if current.position == end {
                if current.steps > longestPath {
                    longestPath = current.steps
                }
                continue
            }
            
            let neighbors = getNeighbors(current).map { neighbor, distance in
                State(position: neighbor, steps: current.steps + distance, path: current.path.plus(neighbor))
            }
            
            for neighbor in neighbors {
                stack.push(neighbor)
            }
        }
        
        return longestPath
    }
}

// MARK: - PART 2

extension Day23 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let decisionPoints = findDecisionPoints(input: input)
        let reducedGrid = decisionPoints.reduce(into: [Coordinate: [Coordinate: Int]]()) { dict, point in
            dict[point] = reduceGridFromPoint(grid: input, from: point, toAnyOther: decisionPoints)
        }
        
        return traverse(input: input) { current in
            return reducedGrid[current.position]!.keys.filter {
                !current.path.contains($0)
            }.map { ($0, reducedGrid[current.position]![$0]!) }
        }
    }
    
    private static func findDecisionPoints(input: Input) -> Set<Coordinate> {
        let start = Coordinate(x: 1, y: 0)
        let end = Coordinate(x: input[0].lastIndex - 1, y: input.lastIndex)

        var decisionPoints = Set<Coordinate>([start, end])
        
        for (y, row) in input.enumerated() {
            for (x, c) in row.enumerated() {
                if c != "#" {
                    let next = Coordinate(x: x, y: y)
                    if next.neighbors().filter({ input.indices.contains($0.y) && input[0].indices.contains($0.x) && input[$0.y][$0.x] != "#" }).count > 2 {
                        decisionPoints.insert(next)
                    }
                }
            }
        }
        
        return decisionPoints
    }
    
    private static func reduceGridFromPoint(grid: Input, from: Coordinate, toAnyOther: Set<Coordinate>) -> [Coordinate: Int] {
        var queue = Deque<(Coordinate, Int)>()
        queue.append((from, 0))
        
        var seen = Set<Coordinate>([from])
        var answer = [Coordinate: Int]()
        
        while !queue.isEmpty {
            let (location, distance) = queue.removeFirst()
            
            if location != from && toAnyOther.contains(location) {
                answer[location] = distance
            } else {
                location
                    .neighbors()
                    .filter { grid.indices.contains($0.y) && grid[0].indices.contains($0.x) }
                    .filter { grid[$0.y][$0.x] != "#" }
                    .filter { !seen.contains($0) }
                    .forEach {
                        seen.insert($0)
                        queue.append(($0, distance + 1))
                    }
            }
        }
        
        return answer
    }
}
