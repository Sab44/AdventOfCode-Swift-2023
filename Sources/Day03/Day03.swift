//
//  Day03.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

@main
struct Day03: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day03 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var symbolCoordinates: [Coordinate] = []
        
        for y in input.indices {
            for x in input[y].indices {
                if input[y][x] != "." && !input[y][x].isNumber {
                    symbolCoordinates.append(Coordinate(x: x, y: y))
                }
            }
        }
        
        var partNumbers: [Int] = []
        
        for coordinate in symbolCoordinates {
            searchNumbers(at: coordinate, input: input, partNumbers: &partNumbers)
        }

        return partNumbers.sum()
    }
    
    private static func searchNumbers(at coordinate: Coordinate, input: [[Character]], partNumbers: inout [Int]) {
        if let top = checkForNumber(coordinate: Coordinate(x: coordinate.x, y: coordinate.y - 1), input: input) {
            partNumbers.append(top)
        } else {
            if let topLeft = checkForNumber(coordinate: Coordinate(x: coordinate.x - 1, y: coordinate.y - 1), input: input) {
                partNumbers.append(topLeft)
            }
            if let topRight = checkForNumber(coordinate: Coordinate(x: coordinate.x + 1, y: coordinate.y - 1), input: input) {
                partNumbers.append(topRight)
            }
        }
        
        if let left = checkForNumber(coordinate: Coordinate(x: coordinate.x - 1, y: coordinate.y), input: input) {
            partNumbers.append(left)
        }
        if let right = checkForNumber(coordinate: Coordinate(x: coordinate.x + 1, y: coordinate.y), input: input) {
            partNumbers.append(right)
        }
        
        if let bottom = checkForNumber(coordinate: Coordinate(x: coordinate.x, y: coordinate.y + 1), input: input) {
            partNumbers.append(bottom)
        } else {
            if let bottomLeft = checkForNumber(coordinate: Coordinate(x: coordinate.x - 1, y: coordinate.y + 1), input: input) {
                partNumbers.append(bottomLeft)
            }
            if let bottomRight = checkForNumber(coordinate: Coordinate(x: coordinate.x + 1, y: coordinate.y + 1), input: input) {
                partNumbers.append(bottomRight)
            }
        }
    }
    
    private static func checkForNumber(coordinate: Coordinate, input: [[Character]]) -> Int? {
        guard input.indices.contains(coordinate.y) && input[coordinate.y][coordinate.x].isNumber else {
            return nil
        }
        
        let line = input[coordinate.y]
        
        // go left
        var leftDigits: [Character] = []
        var leftX = coordinate.x - 1
        while line.indices.contains(leftX) && line[leftX].isNumber {
            leftDigits.insert(line[leftX], at: 0)
            leftX = leftX - 1
        }
        
        // go right
        var rightDigits: [Character] = []
        var rightX = coordinate.x + 1
        while line.indices.contains(rightX) && line[rightX].isNumber {
            rightDigits.append(line[rightX])
            rightX = rightX + 1
        }
        
        let lefts = leftDigits.reduce("", { String($0) + String($1) })
        let rights = rightDigits.reduce("", { String($0) + String($1) })
        
        return Int(lefts + String(input[coordinate.y][coordinate.x]) + rights)!
    }
}

// MARK: - PART 2

extension Day03 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var gearCoordinates: [Coordinate] = []
        
        for y in input.indices {
            for x in input[y].indices {
                if input[y][x] == "*" {
                    gearCoordinates.append(Coordinate(x: x, y: y))
                }
            }
        }
        
        var gearRatios: [Int] = []
        
        for coordinate in gearCoordinates {
            var partNumbers: [Int] = []
            
            searchNumbers(at: coordinate, input: input, partNumbers: &partNumbers)
            
            if partNumbers.count == 2 {
                gearRatios.append(partNumbers[0] * partNumbers[1])
            }
        }

        return gearRatios.sum()
    }
}
