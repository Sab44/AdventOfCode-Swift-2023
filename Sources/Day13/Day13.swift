//
//  Day13.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Pattern: Parsable {
    let patterns: [[[Character]]]
    
    static func parse(raw: String) throws -> Pattern {
        let inputLines = raw.components(separatedBy: .newlines)
        var patterns: [[[Character]]] = []
        patterns.append([])
        
        for line in inputLines {
            if line == "" {
                patterns.append([])
                continue
            }
            patterns[patterns.lastIndex].append(Array(line))
        }
        return Pattern(patterns: patterns)
    }
}

@main
struct Day13: Puzzle {
    typealias Input = Pattern
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day13 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var result = 0
        
        for (_, pattern) in input.patterns.enumerated() {
            // check horizontal reflection
            var rowsAbove = 0
            // 1) check from top
            var i = 0
            while 2*i < pattern.lastIndex {
                let topRange = 0...i
                let bottomRange = (i + 1)...(i + i + 1)
                
                let top: [[Character]] = Array(pattern[topRange])
                let bottom: [[Character]] = Array(pattern[bottomRange].reversed())
                
                if top == bottom {
                    rowsAbove = top.count
                    break
                }
                i += 1
            }
            // 2) check from bottom
            if rowsAbove == 0 {
                var iBottom = pattern.lastIndex
                while 2*iBottom > pattern.lastIndex {
                    let bottomRange = iBottom...pattern.lastIndex
                    let topRange = (2*iBottom - pattern.lastIndex - 1)...(iBottom - 1)
                    
                    let top: [[Character]] = Array(pattern[topRange])
                    let bottom: [[Character]] = Array(pattern[bottomRange].reversed())
                    
                    if top == bottom {
                        rowsAbove = pattern.count - bottom.count
                        break
                    }
                    iBottom -= 1
                }
            }
            result += rowsAbove * 100
            
            // check vertical reflection
            var columnsToLeft = 0
            // 1) check from left
            var j = 0
            while 2*j < pattern[0].lastIndex {
                let leftRange = 0...j
                let rightRange = (j + 1)...(j + j + 1)
                
                let left: [[Character]] = pattern.map { Array($0[leftRange]) }
                let right: [[Character]] = pattern.map { Array($0[rightRange].reversed()) }
                
                if left == right {
                    columnsToLeft = left[0].count
                    break
                }
                j += 1
            }
            // 2) check from right
            if columnsToLeft == 0 {
                var jRight = pattern[0].lastIndex
                while 2*jRight > pattern[0].lastIndex {
                    let rightRange = jRight...pattern[0].lastIndex
                    let leftRange = (2*jRight - pattern[0].lastIndex - 1)...(jRight - 1)
                    
                    let left: [[Character]] = pattern.map { Array($0[leftRange]) }
                    let right: [[Character]] = pattern.map { Array($0[rightRange].reversed()) }
                    
                    if left == right {
                        columnsToLeft = pattern[0].count - right[0].count
                        break
                    }
                    jRight -= 1
                }
            }
            result += columnsToLeft
            
        }
        return result
    }
}

// MARK: - PART 2

extension Day13 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var result = 0
        
        for (_, pattern) in input.patterns.enumerated() {
            // check horizontal reflection
            var rowsAbove = 0
            // 1) check from top
            var i = 0
            var horizontalSmudge: (Int, Int)? = nil
            while 2*i < pattern.lastIndex {
                let topRange = 0...i
                let bottomRange = (i + 1)...(i + i + 1)
                
                var top: [[Character]] = Array(pattern[topRange])
                if let smudge = horizontalSmudge {
                    let current = top[smudge.0][smudge.1]
                    top[smudge.0][smudge.1] = current == "#" ? "." : "#"
                }
                let bottom: [[Character]] = Array(pattern[bottomRange].reversed())
                
                if horizontalSmudge == nil, let smudge = hasSmudge(first: top, second: bottom) {
                    horizontalSmudge = smudge
                    let current = top[smudge.0][smudge.1]
                    top[smudge.0][smudge.1] = current == "#" ? "." : "#"
                }
                
                if top == bottom && horizontalSmudge != nil {
                    rowsAbove = top.count
                    break
                }
                i += 1
            }
            // 2) check from bottom
            if rowsAbove == 0 {
                var iBottom = pattern.lastIndex
                while 2*iBottom > pattern.lastIndex {
                    let bottomRange = iBottom...pattern.lastIndex
                    let topRange = (2*iBottom - pattern.lastIndex - 1)...(iBottom - 1)
                    
                    var top: [[Character]] = Array(pattern[topRange])
                    if let smudge = horizontalSmudge {
                        let current = top[smudge.0][smudge.1]
                        top[smudge.0][smudge.1] = current == "#" ? "." : "#"
                    }
                    let bottom: [[Character]] = Array(pattern[bottomRange].reversed())
                    
                    if horizontalSmudge == nil, let smudge = hasSmudge(first: top, second: bottom) {
                        horizontalSmudge = smudge
                        let current = top[smudge.0][smudge.1]
                        top[smudge.0][smudge.1] = current == "#" ? "." : "#"
                    }
                    
                    if top == bottom && horizontalSmudge != nil {
                        rowsAbove = pattern.count - bottom.count
                        break
                    }
                    iBottom -= 1
                }
            }
            result += rowsAbove * 100
            
            // check vertical reflection
            var columnsToLeft = 0
            // 1) check from left
            var j = 0
            var verticalSmudge: (Int, Int)? = nil
            while 2*j < pattern[0].lastIndex {
                let leftRange = 0...j
                let rightRange = (j + 1)...(j + j + 1)
                
                var left: [[Character]] = pattern.map { Array($0[leftRange]) }
                if let smudge = verticalSmudge {
                    let current = left[smudge.0][smudge.1]
                    left[smudge.0][smudge.1] = current == "#" ? "." : "#"
                }
                let right: [[Character]] = pattern.map { Array($0[rightRange].reversed()) }
                
                if verticalSmudge == nil, let smudge = hasSmudge(first: left, second: right) {
                    verticalSmudge = smudge
                    let current = left[smudge.0][smudge.1]
                    left[smudge.0][smudge.1] = current == "#" ? "." : "#"
                }
                
                if left == right && verticalSmudge != nil {
                    columnsToLeft = left[0].count
                    break
                }
                j += 1
            }
            // 2) check from right
            if columnsToLeft == 0 {
                var jRight = pattern[0].lastIndex
                while 2*jRight > pattern[0].lastIndex {
                    let rightRange = jRight...pattern[0].lastIndex
                    let leftRange = (2*jRight - pattern[0].lastIndex - 1)...(jRight - 1)
                    
                    var left: [[Character]] = pattern.map { Array($0[leftRange]) }
                    if let smudge = verticalSmudge {
                        let current = left[smudge.0][smudge.1]
                        left[smudge.0][smudge.1] = current == "#" ? "." : "#"
                    }
                    let right: [[Character]] = pattern.map { Array($0[rightRange].reversed()) }
                    
                    if verticalSmudge == nil, let smudge = hasSmudge(first: left, second: right) {
                        verticalSmudge = smudge
                        let current = left[smudge.0][smudge.1]
                        left[smudge.0][smudge.1] = current == "#" ? "." : "#"
                    }
                    
                    if left == right && verticalSmudge != nil {
                        columnsToLeft = pattern[0].count - right[0].count
                        break
                    }
                    jRight -= 1
                }
            }
            result += columnsToLeft
        }
        return result
    }
    
    private static func hasSmudge(first: [[Character]], second: [[Character]]) -> (Int, Int)? {
        var differences = 0
        var differenceAt: (Int, Int)? = nil
        for i in first.indices {
            let differencesInLine = first[i].enumerated().filter { j, element in
                if element != second[i][j] {
                    differenceAt = (i, j)
                    return true
                }
                return false
            }.count
            differences += differencesInLine
        }
        if differences == 1 {
            return differenceAt
        }
        return nil
    }
}
