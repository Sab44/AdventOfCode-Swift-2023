//
//  Day14.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day14: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day14 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var roundRocks: [Coordinate] = []
        for i in input.indices {
            for j in input[i].indices {
                if input[i][j] == "O" {
                    roundRocks.append(Coordinate(x: j, y: i))
                }
            }
        }
        
        var cubeRocks: [Coordinate] = []
        for i in input.indices {
            for j in input[i].indices {
                if input[i][j] == "#" {
                    cubeRocks.append(Coordinate(x: j, y: i))
                }
            }
        }
        
        // tilt north
        var tilted = input
        for roundRock in roundRocks {
            if roundRock.y == 0 {
                continue
            }
            
            var newY = roundRock.y - 1
            
            while tilted.indices.contains(newY) && tilted[newY][roundRock.x] == "." {
                newY -= 1
            }
            
            tilted[roundRock.y][roundRock.x] = "."
            tilted[newY + 1][roundRock.x] = "O"
        }
        
        var load = 0
        for i in tilted.indices {
            for j in tilted[i].indices {
                if tilted[i][j] == "O" {
                    load += (tilted.count - i)
                }
            }
        }
        
        return load
    }
}

// MARK: - PART 2

extension Day14 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var roundRocks: [Coordinate] = []
        findRoundRocks(input: input, roundRocks: &roundRocks)
        
        var cubeRocks: [Coordinate] = []
        for i in input.indices {
            for j in input[i].indices {
                if input[i][j] == "#" {
                    cubeRocks.append(Coordinate(x: j, y: i))
                }
            }
        }
        
        // tilt
        var tilted = input
        
        var results: [[[Character]]] = []
        while !results.contains(tilted) {
            results.append(tilted)
            tilt(tilted: &tilted, roundRocks: &roundRocks)
        }
        
        let previousCycles = results.firstIndex(of: tilted)!
        let loop = results.count - previousCycles
        let additionalRuns = (1000000000 - previousCycles) % loop
        
        for _ in 0..<additionalRuns {
            tilt(tilted: &tilted, roundRocks: &roundRocks)
        }
        
        var load = 0
        for i in tilted.indices {
            for j in tilted[i].indices {
                if tilted[i][j] == "O" {
                    load += (tilted.count - i)
                }
            }
        }
        
        return load
    }
    
    private static func tilt(tilted: inout Input, roundRocks: inout [Coordinate]) {
        // tilt north
        for roundRock in roundRocks {
            if roundRock.y == 0 {
                continue
            }
            
            var newY = roundRock.y - 1
            
            while tilted.indices.contains(newY) && tilted[newY][roundRock.x] == "." {
                newY -= 1
            }
            
            tilted[roundRock.y][roundRock.x] = "."
            tilted[newY + 1][roundRock.x] = "O"
        }
        findRoundRocks(input: tilted, roundRocks: &roundRocks)
        
        // tilt west
        for roundRock in roundRocks {
            if roundRock.x == 0 {
                continue
            }
            
            var newX = roundRock.x - 1
            
            while tilted[roundRock.y].indices.contains(newX) && tilted[roundRock.y][newX] == "." {
                newX -= 1
            }
            
            tilted[roundRock.y][roundRock.x] = "."
            tilted[roundRock.y][newX + 1] = "O"
        }
        findRoundRocks(input: tilted, roundRocks: &roundRocks)
        
        // tilt south
        for roundRock in roundRocks.reversed() {
            if roundRock.y == tilted.lastIndex {
                continue
            }
            
            var newY = roundRock.y + 1
            
            while tilted.indices.contains(newY) && tilted[newY][roundRock.x] == "." {
                newY += 1
            }
            
            tilted[roundRock.y][roundRock.x] = "."
            tilted[newY - 1][roundRock.x] = "O"
        }
        findRoundRocks(input: tilted, roundRocks: &roundRocks)
        
        // tilt east
        for roundRock in roundRocks.reversed() {
            if roundRock.x == tilted[roundRock.y].lastIndex {
                continue
            }
            
            var newX = roundRock.x + 1
            
            while tilted[roundRock.y].indices.contains(newX) && tilted[roundRock.y][newX] == "." {
                newX += 1
            }
            
            tilted[roundRock.y][roundRock.x] = "."
            tilted[roundRock.y][newX - 1] = "O"
        }
        findRoundRocks(input: tilted, roundRocks: &roundRocks)
    }
    
    private static func findRoundRocks(input: Input, roundRocks: inout [Coordinate]) {
        roundRocks = []
        for i in input.indices {
            for j in input[i].indices {
                if input[i][j] == "O" {
                    roundRocks.append(Coordinate(x: j, y: i))
                }
            }
        }
    }
}
