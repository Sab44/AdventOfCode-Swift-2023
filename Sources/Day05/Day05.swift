//
//  Day05.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Almanac: Parsable {
    static let mapIdentifiers = [
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
        
        for index in mapIdentifiers.indices {
            let endIndex = index == mapIdentifiers.lastIndex ? (lines.endIndex + 1) : lines.firstIndex { $0.contains(mapIdentifiers[index + 1]) }!
            
            let currentMap = Array(lines[
                (lines.firstIndex { $0.contains(mapIdentifiers[index]) }! + 1)..<(endIndex - 1)
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
        var seedRanges = [Range<Int>]()
        for index in input.seeds.indices {
            if index % 2 != 0 {
                continue
            }
            
            let range = (input.seeds[index] + 0)..<(input.seeds[index] + input.seeds[index + 1])
            seedRanges.append(range)
        }
        
        var currentRanges = seedRanges
        for mapIndex in Almanac.mapIdentifiers.indices {
            var newRanges = [Range<Int>]()
            for range in currentRanges {
                for newRange in resourceRangeToLocationRanges(almanac: input, mapIndex: mapIndex, sourceRange: range) {
                    newRanges.append(newRange)
                }
            }
            currentRanges = newRanges
        }
        
        return currentRanges.min { $0.lowerBound < $1.lowerBound }!.lowerBound
    }
    
    private static func resourceRangeToLocationRanges(almanac: Input, mapIndex: Int, sourceRange: Range<Int>) -> [Range<Int>] {
        if mapIndex > Almanac.mapIdentifiers.lastIndex {
            return [sourceRange]
        }
        
        let possibleDestinations = almanac.maps[mapIndex].map {
            let rangeShift = $0.destinationStart - $0.sourceStart
            return ($0.sourceStart..<($0.sourceStart + $0.range), rangeShift)
        }.sorted {
            $0.0.lowerBound < $1.0.lowerBound
        }
        
        var destinationRanges = [Range<Int>]()
        
        // If the sourceRange starts before the first possibleDestinationRange,
        // then we need to add that non-overlapping part to the destinations as-is
        let (firstPossibleDestinationRange, _) = possibleDestinations.first!
        if sourceRange.lowerBound < firstPossibleDestinationRange.lowerBound {
            let prefixRangeEnd = min(sourceRange.upperBound, firstPossibleDestinationRange.lowerBound)
            let prefixRange = sourceRange.lowerBound..<prefixRangeEnd
            destinationRanges.append(prefixRange)
        }
        
        // Now, check over all the possibleDestinations and, for every destinationRange
        // that overlaps sourceRange, apply the offset to the overlapping portion of and
        // add it to the destinations
        for (destinationRange, offset) in possibleDestinations {
            if sourceRange.lowerBound < destinationRange.upperBound && destinationRange.lowerBound < sourceRange.upperBound {
                let overlappingRangeStart = max(sourceRange.lowerBound, destinationRange.lowerBound)
                let overlappingRangeEnd = min(sourceRange.upperBound, destinationRange.upperBound)
                let overlappingRange = (overlappingRangeStart + offset)..<(overlappingRangeEnd + offset)
                destinationRanges.append(overlappingRange)
            }
        }
        
        // Finally, if sourceRange extends past the end of the last destinationRange,
        // then we need to add that non-overlapping part to the destinations as-is.
        let (lastPossibleDestinationRange, _) = possibleDestinations.last!
        if sourceRange.upperBound > lastPossibleDestinationRange.upperBound {
            let suffixRangeStart = max(sourceRange.lowerBound, lastPossibleDestinationRange.upperBound)
            let suffixRange = suffixRangeStart..<sourceRange.upperBound
            destinationRanges.append(suffixRange)
        }
        
        return destinationRanges
    }
}
