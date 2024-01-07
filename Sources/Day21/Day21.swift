//
//  Day21.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day21: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day21 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let startY = input.firstIndex { $0.contains("S") }!
        let startX = input[startY].firstIndex(of: "S")!
        let start = Coordinate(x: startX, y: startY)
        
        var currentPlots: Set<Coordinate> = [start]
        
        for _ in 0..<64 {
            var nextPlots = Set<Coordinate>()
            
            for plot in currentPlots {
                for neighbor in getNeighbors(input: input, position: plot) {
                    nextPlots.insert(neighbor)
                }
            }
            
            currentPlots = nextPlots
        }
        
       
        return currentPlots.count
    }
    
    private static func getNeighbors(input: Input, position: Coordinate) -> [Coordinate] {
        var neighbors = [Coordinate]()
        if let left = input[position.y].getOrNil(index: position.x - 1), left != "#" {
            neighbors.append(Coordinate(x: position.x - 1, y: position.y))
        }
        if let top = input.getOrNil(index: position.y - 1)?[position.x], top != "#" {
            neighbors.append(Coordinate(x: position.x, y: position.y - 1))
        }
        if let right = input[position.y].getOrNil(index: position.x + 1), right != "#" {
            neighbors.append(Coordinate(x: position.x + 1, y: position.y))
        }
        if let bottom = input.getOrNil(index: position.y + 1)?[position.x], bottom != "#" {
            neighbors.append(Coordinate(x: position.x, y: position.y + 1))
        }
        return neighbors
    }
}

// MARK: - PART 2

extension Day21 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
