//
//  Day21.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common
import Collections

@main
struct Day21: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day21 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        return countSteps(input: input, max: 64).values.filter { $0 % 2 == 0 }.count
    }
    
    private static func countSteps(input: Input, max: Int) -> [Coordinate: Int] {
        let startY = input.firstIndex { $0.contains("S") }!
        let startX = input[startY].firstIndex(of: "S")!
        let start = Coordinate(x: startX, y: startY)
        
        var queue = Deque<(Coordinate, Int)>()
        queue.append((start, 0))
        
        var result = [Coordinate: Int]()
        
        while !queue.isEmpty {
            let (location, distance) = queue.removeFirst()
            
            if !result.keys.contains(location) && distance <= max {
                result[location] = distance
                let next = location
                    .neighbors()
                    .filter { !result.keys.contains($0) }
                    .filter { input.indices.contains($0.y) && input[0].indices.contains($0.x) }
                    .filter { input[$0.y][$0.x] != "#" }
                    .map { ($0, distance + 1) }
                
                queue.append(contentsOf: next)
            }
        }
        
        return result
    }
}

// MARK: - PART 2

extension Day21 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let stepCount = 26501365
        
        // https://todd.ginsberg.com/post/advent-of-code/2023/day21/
        let steps = countSteps(input: input, max: input.count)
        let oddCorners = steps.filter { $0.value % 2 == 1 && $0.value > 65 }.count
        let evenCorners = steps.filter { $0.value % 2 == 0 && $0.value > 65 }.count
        let evenBlock = steps.values.filter { $0 % 2 == 0 }.count
        let oddBlock = steps.values.filter { $0 % 2 == 1 }.count
        
        let n = (stepCount - (input.count / 2)) / input.count
        
        let even = n * n
        let odd = (n + 1) * (n + 1)
        
        return (odd * oddBlock) + (even * evenBlock) - ((n + 1) * oddCorners) + (n * evenCorners)
    }
}
