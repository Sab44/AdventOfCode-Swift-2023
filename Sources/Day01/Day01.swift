//
//  Day01.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day01: Puzzle {
    typealias Input = [String]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day01 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var results: [String] = []
        
        input.forEach { line in
            let firstDigit = String(line.first { $0.isNumber }!)
            let lastDigit = String(line.last { $0.isNumber }!)
            
            results.append(firstDigit + lastDigit)
        }
        
        return results.map { Int($0)! }.sum()
    }
}

// MARK: - PART 2

extension Day01 {
    private static let stringNumbers = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var results: [String] = []
        
        input.forEach { line in
            var firstDigit = ""
            
        outerLoop: while (true) {
            for charIndex in 1...line.count {
                let substring = String(Array(line).prefix(upTo: charIndex))
                if let lastChar = substring.last, lastChar.isNumber {
                    firstDigit = String(lastChar)
                    break outerLoop
                }
                if let numberAsWord = stringNumbers.first(where: { substring.range(of: $0) != nil }) {
                    firstDigit = String(stringNumbers.firstIndex(of: numberAsWord)! + 1)
                    break outerLoop
                }
            }
        }
            
            var lastDigit = ""
            
        outerLoop: while (true) {
            for charIndex in 1...line.count {
                let substring = String(Array(line).suffix(charIndex))
                if let firstChar = substring.first, firstChar.isNumber {
                    lastDigit = String(firstChar)
                    break outerLoop
                }
                if let numberAsWord = stringNumbers.first(where: { substring.range(of: $0) != nil }) {
                    lastDigit = String(stringNumbers.firstIndex(of: numberAsWord)! + 1)
                    break outerLoop
                }
            }
        }
            
            results.append(firstDigit + lastDigit)
        }
        
        return results.map { Int($0)! }.sum()
    }
}
