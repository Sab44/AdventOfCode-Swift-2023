//
//  Day24.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Hail: Parsable, Hashable {
    let position: Coordinate3D
    let velocity: Coordinate3D
    
    static func parse(raw: String) throws -> Hail {
        let positionCoords = raw.split(separator: "@")[0].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let position = Coordinate3D(x: Int(positionCoords[0])!, y: Int(positionCoords[1])!, z: Int(positionCoords[2])!)
        
        let velocityCoords = raw.split(separator: "@")[1].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let velocity = Coordinate3D(x: Int(velocityCoords[0])!, y: Int(velocityCoords[1])!, z: Int(velocityCoords[2])!)
        
        return Hail(position: position, velocity: velocity)
    }
}

struct Point: Hashable {
    var x: Double
    var y: Double
}

@main
struct Day24: Puzzle {
    typealias Input = [Hail]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day24 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var testAreaMin = 200000000000000.0
        var testAreaMax = 400000000000000.0
        if input.count == 5 {
            // use example input values
            testAreaMin = 7.0
            testAreaMax = 27.0
        }
        
        var hailstones = input
        var hailPairs = [(Hail, Hail)]()
        for hail in input {
            hailstones.remove(at: 0)
            
            for hailstone in hailstones {
                hailPairs.append((hail, hailstone))
            }
        }
        
        var intersections = 0
        
        for (hailA, hailB) in hailPairs {
            let mA = Double(hailA.velocity.y)/Double(hailA.velocity.x)
            let mB = Double(hailB.velocity.y)/Double(hailB.velocity.x)
            
            guard let intersectionPoint = intersectionPoint(line1Point: Coordinate(x: hailA.position.x, y: hailA.position.y), line1Slope: mA,
                                                            line2Point: Coordinate(x: hailB.position.x, y: hailB.position.y), line2Slope: mB) else {
                // parallel
                continue
            }
            
            let (x, y) = (intersectionPoint.x, intersectionPoint.y)
             
            guard (testAreaMin...testAreaMax).contains(x) && (testAreaMin...testAreaMax).contains(y) else {
                // outside of test area
                continue
            }
            
            if (hailA.velocity.x < 0 && x > Double(hailA.position.x)) || (hailA.velocity.x > 0 && x < Double(hailA.position.x)) {
                // paths crossed in the past
                continue
            }
            
            if (hailB.velocity.x < 0 && x > Double(hailB.position.x)) || (hailB.velocity.x > 0 && x < Double(hailB.position.x)) {
                // paths crossed in the past
                continue
            }
            
            intersections += 1
        }
        
        return intersections
    }
    
    private static func intersectionPoint(line1Point: Coordinate, line1Slope: Double,
                                          line2Point: Coordinate, line2Slope: Double) -> Point? {
        // Check if lines are parallel
        if line1Slope == line2Slope {
            // Lines are parallel (or coincident), no intersection or infinite intersections
            return nil
        }
        
        // Calculate the y-intercept of line 1
        let b1 = Double(line1Point.y) - (line1Slope * Double(line1Point.x))
        
        // Calculate the y-intercept of line 2
        let b2 = Double(line2Point.y) - (line2Slope * Double(line2Point.x))
        
        // Calculate the x coordinate of the intersection point
        let x = (b2 - b1) / (line1Slope - line2Slope)
        
        // Calculate the y coordinate of the intersection point
        let y = (line1Slope * x) + b1
        
        return Point(x: x, y: y)
    }
}

// MARK: - PART 2

extension Day24 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
