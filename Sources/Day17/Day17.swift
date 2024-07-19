//
//  Day17.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct State: Hashable {
    let position: Coordinate
    let direction: Direction?
    let chainLength: Int

    init(position: Coordinate, direction: Direction? = nil, chainLength: Int = 0) {
        self.position = position
        self.direction = direction
        self.chainLength = chainLength
    }
}

struct City: Pathfinding {
    private let grid: [[Int]]
    private let chainRange: ClosedRange<Int>

    init(grid: [[Int]], chainRange: ClosedRange<Int>) {
        self.grid = grid
        self.chainRange = chainRange
    }

    func neighbors(for state: State) -> [State] {
        var result = [State]()
        for dir in Direction.allCases {
            if let direction = state.direction {
                if direction == dir.opposite {
                    continue
                }
                if direction == dir && state.chainLength == chainRange.upperBound {
                    continue
                }
                if direction != dir && state.chainLength < chainRange.lowerBound {
                    continue
                }
            }
            let position = state.position.moved(to: dir)
            if !isInside(position) {
                continue
            }
            let chainLength = dir == state.direction ? state.chainLength + 1 : 1
            result.append(State(position: position, direction: dir, chainLength: chainLength))
        }
        return result
    }

    func goalReached(at current: State, goal: State) -> Bool {
        current.position == goal.position && current.chainLength >= chainRange.lowerBound
    }

    func costToMove(from: State, to: State) -> Int {
        grid[to.position.y][to.position.x]
    }

    func distance(from: State, to: State) -> Int {
        1
    }

    private func isInside(_ point: Coordinate) -> Bool {
        0 ..< grid.count ~= point.y && 0 ..< grid[0].count ~= point.x
    }
}

@main
struct Day17: Puzzle {
    typealias Input = [[Int]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day17 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let city = City(grid: input, chainRange: 0...3)
        return totalHeatloss(input: input, city: city)
    }
}

extension Day17 {
    private static func totalHeatloss(input: Input, city: City) -> Int {
        let pathfinder = AStarPathfinder(map: city)

        let start = State(position: .zero)
        let goal = State(position: Coordinate(x: input[0].lastIndex, y: input.lastIndex))
        let path = pathfinder.shortestPath(from: start, to: goal)

        return path.map { input[$0.position.y][$0.position.x] }.reduce(0, +)
    }
}

// MARK: - PART 2

extension Day17 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let city = City(grid: input, chainRange: 4...10)
        return totalHeatloss(input: input, city: city)
    }
}
