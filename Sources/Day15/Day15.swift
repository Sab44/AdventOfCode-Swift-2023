//
//  Day15.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day15: Puzzle {
    typealias Input = String
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day15 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let instructions: [[Character]] = input.components(separatedBy: ",").map { Array($0) }
        
        return instructions.map { runHash(instruction: $0)}.sum()
    }
}

extension Day15 {
    private static func runHash(instruction: [Character]) -> Int {
        var currentValue = 0
        instruction.forEach { char in
            currentValue += Int(char.asciiValue!)
            currentValue = (currentValue * 17) % 256
        }
        return currentValue
    }
}

// MARK: - PART 2

extension Day15 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var hashmap: [Int: [String]] = [:]
        let instructions: [String] = input.components(separatedBy: ",")
        
        instructions.forEach { instruction in
            let label = instruction.contains("=") ? instruction.components(separatedBy: "=")[0] : String(instruction.dropLast(1))
            
            let box = runHash(instruction: Array(label))
            
            if instruction.last == "-" {
                if var lenses = hashmap[box] {
                    if let lensIndex = lenses.firstIndex(where: { element in
                        String(element.split(separator: " ")[0]) == label
                    }) {
                        lenses.remove(at: lensIndex)
                        hashmap[box] = lenses
                    }
                }
            } else if instruction.contains("=") {
                let lens = label + " " + instruction.components(separatedBy: "=")[1]
                if var lenses = hashmap[box] {
                    if let lensIndex = lenses.firstIndex(where: { element in
                        String(element.split(separator: " ")[0]) == label
                    }) {
                        lenses.remove(at: lensIndex)
                        lenses.insert(lens, at: lensIndex)
                        hashmap[box] = lenses
                    } else {
                        lenses.append(lens)
                        hashmap[box] = lenses
                    }
                } else {
                    hashmap[box] = [lens]
                }
            }
        }
        
        var focusingPowers: [Int] = []
        hashmap.forEach { (key: Int, value: [String]) in
            value.enumerated().forEach { lensIndex, lens in
                var focusingPower = key + 1
                focusingPower *= (lensIndex + 1)
                focusingPower *= Int(lens.split(separator: " ")[1])!
                focusingPowers.append(focusingPower)
            }
        }
        
        return focusingPowers.sum()
    }
}
