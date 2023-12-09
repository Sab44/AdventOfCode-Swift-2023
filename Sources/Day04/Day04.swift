//
//  Day04.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Scratchcard: Parsable {
    let id: Int
    let winningNumbers: Set<Int>
    let cardNumbers: Set<Int>
    
    static func parse(raw: String) throws -> Scratchcard {
        let id = Int(raw.components(separatedBy: ":")[0].dropFirst(5).trimmingCharacters(in: .whitespaces))!
        let winningNumbers = Set(
            raw.split(separator: ": ")[1].split(separator: " | ")[0]
                .split(separator: " ", omittingEmptySubsequences: true)
                .map { Int($0)! }
        )
        let cardNumbers = Set(
            raw.split(separator: ": ")[1].split(separator: " | ")[1]
                .split(separator: " ", omittingEmptySubsequences: true)
                .map { Int($0)! }
        )
        
        return Scratchcard(id: id, winningNumbers: winningNumbers, cardNumbers: cardNumbers)
    }
}

@main
struct Day04: Puzzle {
    typealias Input = [Scratchcard]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day04 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var points: Int = 0
        
        input.forEach { scratchcard in
            let matches = scratchcard.cardNumbers.filter { scratchcard.winningNumbers.contains($0) }.count
            if matches > 0 {
                points += Int(pow(2, Double(matches-1)))
            }
        }
        
        return points
    }
}

// MARK: - PART 2

extension Day04 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var scratchcards: [Int: Int] = Dictionary(uniqueKeysWithValues: input.map { ($0.id, 1)})
        
        input.forEach { scratchcard in
            let multiplicator = scratchcards[scratchcard.id]!
            
            let matches = scratchcard.cardNumbers.filter { scratchcard.winningNumbers.contains($0) }.count
            
            if matches > 0 {
                for id in (scratchcard.id + 1)...(scratchcard.id + matches) {
                    scratchcards[id] = scratchcards[id]! + multiplicator
                }
            }
        }
        
        return scratchcards.values.sum()
    }
}
