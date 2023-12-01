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
            let firstDigitIndex = line.firstIndex { $0.isNumber } ?? line.endIndex
            let firstDigitSubstring = String(line[..<firstDigitIndex])
            
            let firstPresentStringNumbers = stringNumbers.filter({ firstDigitSubstring.contains($0) })
            let firstDigit: String
            if firstPresentStringNumbers.count > 0 {
                firstDigit = findStringNumber(presentNumbers: firstPresentStringNumbers, substring: firstDigitSubstring, reverse: false)
            } else {
                firstDigit = String(line.first { $0.isNumber }!)
            }
            
            let lastDigitIndex = line.lastIndex { $0.isNumber } ?? line.startIndex
            let lastDigitSubstring = String(line[lastDigitIndex..<line.endIndex])
            
            let lastPresentStringNumbers = stringNumbers.filter({ lastDigitSubstring.contains($0) })
            let lastDigit: String
            if lastPresentStringNumbers.count > 0 {
                lastDigit = findStringNumber(presentNumbers: lastPresentStringNumbers, substring: lastDigitSubstring, reverse: true)
            } else {
                lastDigit = String(line.last { $0.isNumber }!)
            }
            
            results.append(firstDigit + lastDigit)
        }
        
        return results.map { Int($0)! }.sum()
    }
    
    private static func findStringNumber(presentNumbers: [String], substring: String, reverse: Bool) -> String {
        let substring = reverse ? String(substring.reversed()) : substring
        var digitString = presentNumbers.map { reverse ? String($0.reversed()) : $0 }.sorted {
            substring.range(of: $0)!.lowerBound < substring.range(of: $1)!.lowerBound
        }.first!
        
        if reverse {
            digitString = String(digitString.reversed())
        }
        
        return String(stringNumbers.firstIndex(of: digitString)! + 1)
    }
}
