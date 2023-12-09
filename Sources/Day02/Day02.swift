//
//  Day02.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Game: Parsable {
    enum CubeColor: String {
        case red
        case green
        case blue
    }
    
    let id: Int
    let draws: [[CubeColor: Int]]
    
    static func parse(raw: String) throws -> Game {
        let id = Int(raw.split(separator: " ")[1].dropLast(1))!
        let draws = raw.split(separator: ": ")[1].split(separator: "; ")
            .map { draw in
                draw.split(separator: ", ")
                    .reduce(into: [CubeColor: Int]()) {
                        let cubeColor = CubeColor(rawValue: $1.components(separatedBy: " ")[1])!
                        $0[cubeColor] = Int($1.split(separator: " ")[0])!
                }
            }
        
        return Game(id: id, draws: draws)
    }
}


@main
struct Day02: Puzzle {
    typealias Input = [Game]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day02 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var possibleGameIds: [Int] = []
        
        input.forEach { game in
            var maxReds = 0
            var maxGreens = 0
            var maxBlues = 0
            
            game.draws.forEach { draw in
                let reds = draw[Game.CubeColor.red] ?? 0
                maxReds = reds > maxReds ? reds : maxReds
                
                let greens = draw[Game.CubeColor.green] ?? 0
                maxGreens = greens > maxGreens ? greens : maxGreens
                
                let blues = draw[Game.CubeColor.blue] ?? 0
                maxBlues = blues > maxBlues ? blues : maxBlues
            }
            
            if maxReds <= 12 && maxGreens <= 13 && maxBlues <= 14 {
                possibleGameIds.append(game.id)
            }
        }
        
        return possibleGameIds.sum()
    }
}

// MARK: - PART 2

extension Day02 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var powers: [Int] = []
        
        input.forEach { game in
            var minReds = 0
            var minGreens = 0
            var minBlues = 0
            
            game.draws.forEach { draw in
                let reds = draw[Game.CubeColor.red] ?? 0
                minReds = reds > minReds ? reds : minReds
                
                let greens = draw[Game.CubeColor.green] ?? 0
                minGreens = greens > minGreens ? greens : minGreens
                
                let blues = draw[Game.CubeColor.blue] ?? 0
                minBlues = blues > minBlues ? blues : minBlues
            }
            
            powers.append(minReds * minGreens * minBlues)
        }
        
        return powers.sum()
    }
}
