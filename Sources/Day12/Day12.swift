//
//  Day12.swift
//  AoC-Swift-Template
//

import Algorithms
import Foundation

import AoC
import Common

struct SpringConditions: Parsable {
    let conditions: [Character]
    let groups: [Int]
    
    static func parse(raw: String) throws -> SpringConditions {
        let conditions: [Character] = Array(raw.split(separator: " ")[0])
        let groups = raw.split(separator: " ")[1].split(separator: ",").map { Int($0)! }
        
        return SpringConditions(conditions: conditions, groups: groups)
    }
}

@main
struct Day12: Puzzle {
    typealias Input = [SpringConditions]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Never
}

// MARK: - PART 1

extension Day12 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var arrangements: [Int] = []
        
        var permutationMap: [Int: [String]] = [:]
        
        for springConditions in input {
            
            let unknowns = springConditions.conditions.filter { $0 == "?" }.count
            
            if permutationMap[unknowns] == nil {
                let start: [Character] = Array(repeating: ".", count: unknowns)
                var pForUnknowns: [String] = [String(start)]
                
                for n in 0..<unknowns {
                    var p = start
                    for index in 0...n {
                        p[index] = "#"
                    }
                    pForUnknowns.append(String(p))
                }
                
                var all: [String] = []
                for string in pForUnknowns {
                    let pInput: [Character] = Array(string)
                    let uniquePermutations = pInput.uniquePermutations(ofCount: pInput.count).map { String($0) }
                    all.append(contentsOf: uniquePermutations)
                }
                
                permutationMap[unknowns] = Array(all)
            }
            
            let allPermutations = permutationMap[unknowns]!
            
            var possibleArrangements = 0
        outer: for possibleCondition in allPermutations {
            var possibleArrangement = springConditions.conditions
            
            var questionIndex = 0
            for questionMarkIndex in springConditions.conditions.indices.filter({ springConditions.conditions[$0] == "?" }) {
                possibleArrangement[questionMarkIndex] = Array(possibleCondition)[questionIndex]
                questionIndex += 1
            }
            let groups = possibleArrangement.split(separator: ".", omittingEmptySubsequences: true).map { Array($0).count }
            
            if groups.count != springConditions.groups.count {
                continue
            }
            for index in groups.indices {
                if groups[index] != springConditions.groups[index] {
                    continue outer
                }
            }
            possibleArrangements += 1
        }
            arrangements.append(possibleArrangements)
        }
        
        return arrangements.sum()
    }
}

// MARK: - PART 2

extension Day12 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
