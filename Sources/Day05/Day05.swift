//
//  Day05.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Almanac: Parsable {
    static let maps = [
        "seed-to-soil",
        "soil-to-fertilizer",
        "fertilizer-to-water",
        "water-to-light",
        "light-to-temperature",
        "temperature-to-humidity",
        "humidity-to-location"
    ]
    
    let seeds: Array<Int>
    let maps: [[Map]]
    
    struct Map {
        let sourceStart: Int
        let destinationStart: Int
        let range: Int
    }
    
    static func parse(raw: String) throws -> Almanac {
        let lines = raw.components(separatedBy: .newlines)
        let seeds = lines[0].split(separator: ": ")[1].split(separator: " ", omittingEmptySubsequences: true).map { Int($0)! }
        
        var allMaps: [[Map]] = []
        
        for index in maps.indices {
            let endIndex = index == maps.lastIndex ? (lines.endIndex + 1) : lines.firstIndex { $0.contains(maps[index + 1]) }!
            
            let currentMap = Array(lines[
                (lines.firstIndex { $0.contains(maps[index]) }! + 1)..<(endIndex - 1)
            ]).map {
                let components = $0.split(separator: " ")
                return Map(sourceStart: Int(components[1])!, destinationStart: Int(components[0])!, range: Int(components[2])!)
            }
            
            allMaps.append(currentMap)
        }
        
        return Almanac(seeds: seeds, maps: allMaps)
    }
}

@main
struct Day05: Puzzle {
    typealias Input = Almanac
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day05 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var nearestLocation = Int.max
        
        input.seeds.forEach { seed in
            var currentValue = seed
            input.maps.forEach { mapping in
                if let mapToUse = mapping.first(where: { ($0.sourceStart..<($0.sourceStart + $0.range)).contains(currentValue) }) {
                    currentValue = currentValue + (mapToUse.destinationStart - mapToUse.sourceStart)
                }
            }
            
            nearestLocation = min(currentValue, nearestLocation)
        }
        
        return nearestLocation
    }
}

// MARK: - PART 2

extension Day05 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
