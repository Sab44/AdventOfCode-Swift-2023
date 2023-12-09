//
//  Day06.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Races: Parsable {
    let timesAndRecords: [(Int, Int)]
    
    static func parse(raw: String) throws -> Races {
        let times = raw.components(separatedBy: .newlines)[0].split(separator: " ", omittingEmptySubsequences: true).dropFirst(1).map { Int($0)! }
        let records = raw.components(separatedBy: .newlines)[1].split(separator: " ", omittingEmptySubsequences: true).dropFirst(1).map { Int($0)! }
        
        var timesAndRecords: [(Int, Int)] = []
        for index in times.indices {
            timesAndRecords.append((times[index], records[index]))
        }
        
        return Races(timesAndRecords: timesAndRecords)
    }
}

@main
struct Day06: Puzzle {
    typealias Input = Races
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day06 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var numberOfWaysToWin: [Int] = []
        
        for (time, record) in input.timesAndRecords {
            let winPossibilities = calculateWinPossibilities(time: time, record: record)
            numberOfWaysToWin.append(winPossibilities)
        }
        
        return numberOfWaysToWin.reduce(1, *)
    }
}

extension Day06 {
    private static func calculateWinPossibilities(time: Int, record: Int) -> Int {
        let holdTimes = 1..<time
        
        var winPossibilities = 0
        holdTimes.forEach { holdTime in
            let timeLeft = time - holdTime
            
            let distanceTraveled = timeLeft * holdTime
            if distanceTraveled > record {
                winPossibilities += 1
            }
        }
        
        return winPossibilities
    }
}

// MARK: - PART 2

extension Day06 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let time = Int(input.timesAndRecords.map { $0.0 }.reduce("", { String($0) + String($1) }))!
        let record = Int(input.timesAndRecords.map { $0.1 }.reduce("", { String($0) + String($1) }))!

        return calculateWinPossibilities(time: time, record: record)
    }
}
