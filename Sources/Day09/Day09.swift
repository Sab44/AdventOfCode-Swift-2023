//
//  Day09.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day09: Puzzle {
    static func transform(raw: String) async throws -> [[Int]] {
        return raw.components(separatedBy: .newlines).map {
            $0.split(separator: " ").map { Int($0)! }
        }
    }
    
    typealias Input = [[Int]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day09 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let nextValue = calculateNextValue(input: input, nextValueFunction: { nextValue, sequence in
            return sequence.last! + nextValue
        })
        
        return nextValue
    }
}

extension Day09 {
    private static func calculateNextValue(input: Input, nextValueFunction: (Int, Array<Int>) -> Int) -> Int {
        var sequences: [[Int]] = []
        var nextValues: [Int] = []
        
        for history in input {
            sequences.append(history)
            
            while sequences.last!.contains(where: { $0 != 0 }) {
                let currentSequence = sequences.last!
                var nextSequence: [Int] = []
                for index in currentSequence.indices {
                    if index == currentSequence.indices.lastIndex {
                        break
                    }
                    nextSequence.append(currentSequence[index + 1] - currentSequence[index])
                }
                sequences.append(nextSequence)
            }
            
            var nextValue = 0
            for sequenceIndex in sequences.indices.reversed() {
                nextValue = nextValueFunction(nextValue, sequences[sequenceIndex])
            }
            nextValues.append(nextValue)
            sequences = []
        }
        
        return nextValues.sum()
    }
}

// MARK: - PART 2

extension Day09 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let nextValue = calculateNextValue(input: input, nextValueFunction: { nextValue, sequence in
            return sequence.first! - nextValue
        })
        
        return nextValue
    }
}
