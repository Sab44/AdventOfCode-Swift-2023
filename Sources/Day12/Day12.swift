//
//  Day12.swift
//  AoC-Swift-Template
//

import Algorithms
import Foundation

import AoC
import Common

struct SpringConditions: Parsable, Hashable {
    let conditions: [Character]
    let groups: [Int]
    
    static func parse(raw: String) throws -> SpringConditions {
        let conditions: [Character] = Array(raw.split(separator: " ")[0])
        let groups = raw.split(separator: " ")[1].split(separator: ",").map { Int($0)! }
        
        return SpringConditions(conditions: conditions, groups: groups)
    }
    
    var unfolded: SpringConditions {
        let conditions = Array(repeating: self.conditions, count: 5).joined(separator: "?")
        let groups = [[Int]](repeating: self.groups, count: 5).flatMap { $0 }
        return SpringConditions(conditions: Array(conditions), groups: groups)
    }
}

@main
struct Day12: Puzzle {
    typealias Input = [SpringConditions]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day12 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        return input.map { arrangements(springConditions: $0) }.reduce(0, +)
    }
    
    private static var cache = [SpringConditions: Int]()
    
    private static func arrangements(springConditions: SpringConditions) -> Int {
           if let cached = cache[springConditions] {
               return cached
           } else {
               let value = _arrangements(springConditions)
               cache[springConditions] = value
               return value
           }
       }

       private static func _arrangements(_ springConditions: SpringConditions) -> Int {
           if springConditions.groups.isEmpty {
               return springConditions.conditions.contains("#") ? 0 : 1
           }
           if springConditions.conditions.isEmpty {
               return 0
           }

           let ch = springConditions.conditions.first!
           let group = springConditions.groups.first!

           var sum = 0
           if ch == "#" {
               sum = pound(springConditions, group)
           } else if ch == "." {
               sum = dot(springConditions)
           } else if ch == "?" {
               sum = dot(springConditions) + pound(springConditions, group)
           }

           return sum
       }

       private static func dot(_ springConditions: SpringConditions) -> Int {
           arrangements(springConditions: SpringConditions(conditions: Array(springConditions.conditions.dropFirst()),
                                                           groups: springConditions.groups))
       }

       private static func pound(_ springConditions: SpringConditions, _ group: Int) -> Int {
           let thisGroup = springConditions.conditions
               .prefix(group)
               .map { $0 == "?" ? "#" : $0 } // replace ? with #

           if thisGroup != Array<Character>(repeating: "#", count: group) {
               return 0
           }

           if springConditions.conditions.count == group {
               return springConditions.groups.count == 1 ? 1 : 0
           }
           
           if "?.".contains(springConditions.conditions[group]) {
               return arrangements(springConditions: SpringConditions(conditions: Array(springConditions.conditions.dropFirst(group + 1)),
                                                                      groups: Array(springConditions.groups.dropFirst())))
           }
           return 0
       }
}

// MARK: - PART 2

extension Day12 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        return input.map { arrangements(springConditions: $0.unfolded) }.reduce(0, +)
    }
}
