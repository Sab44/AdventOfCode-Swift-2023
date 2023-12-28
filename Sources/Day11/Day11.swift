//
//  Day11.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day11: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day11 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let rowsToExpand = getRowsToExpand(input: input)
        let columnsToExpand = getColumnsToExpand(input: input)
        
        let galaxyPairs = findGalaxyPairs(input: input)
        
        return findSumOfShortestPaths(galaxyPairs: galaxyPairs, rowsToExpand: rowsToExpand, columnsToExpand: columnsToExpand, expandBy: 1)
    }
}

extension Day11 {
    private static func getRowsToExpand(input: Input) -> [Int] {
        return input.indices.filter { input[$0].allSatisfy({ $0 == "." }) }
    }
    
    private static func getColumnsToExpand(input: Input) -> [Int] {
        return input[0].indices.filter { j in
            input.indices.allSatisfy({ input[$0][j] == "." })
        }
    }
    
    private static func findGalaxyPairs(input: Input) -> [Coordinate: [Coordinate]] {
        // Find galaxies
        var galaxies: [Coordinate] = []
        for i in input.indices {
            for j in input[i].indices {
                if input[i][j] == "#" {
                    galaxies.append(Coordinate(x: j, y: i))
                }
            }
        }
        
        // Find galaxy pairs
        var galaxyPairs: [Coordinate: [Coordinate]] = [:]
        for galaxy in galaxies {
            let otherGalaxies = galaxies.filter { $0 != galaxy && !galaxyPairs.keys.contains($0) }
            if !otherGalaxies.isEmpty {
                galaxyPairs[galaxy] = otherGalaxies
            }
        }
        return galaxyPairs
    }
    
    private static func findSumOfShortestPaths(galaxyPairs: [Coordinate: [Coordinate]], rowsToExpand: [Int], columnsToExpand: [Int], expandBy: Int) -> Int {
        var shortestPaths: [Int] = []
        
        for (firstGalaxy, otherGalaxies) in galaxyPairs {
            for secondGalaxy in otherGalaxies {
                let distance = abs(firstGalaxy.x - secondGalaxy.x) + abs(firstGalaxy.y - secondGalaxy.y)
                
                let countX = (min(firstGalaxy.x, secondGalaxy.x)..<max(firstGalaxy.x, secondGalaxy.x)).filter { columnsToExpand.contains($0) }.count
                let countY = (min(firstGalaxy.y, secondGalaxy.y)..<max(firstGalaxy.y, secondGalaxy.y)).filter { rowsToExpand.contains($0) }.count
                
                shortestPaths.append(distance + expandBy * countX + expandBy * countY)
            }
        }
        
        return shortestPaths.sum()
    }
}

// MARK: - PART 2

extension Day11 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let rowsToExpand = getRowsToExpand(input: input)
        let columnsToExpand = getColumnsToExpand(input: input)
        
        let galaxyPairs = findGalaxyPairs(input: input)
        
        return findSumOfShortestPaths(galaxyPairs: galaxyPairs, rowsToExpand: rowsToExpand, columnsToExpand: columnsToExpand, expandBy: 999999)
    }
}
