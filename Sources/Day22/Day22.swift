//
//  Day22.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Brick: Hashable {
    let id: Int
    let start: Coordinate3D
    let end: Coordinate3D
}

@main
struct Day22: Puzzle {
    static func transform(raw: String) async throws -> [Brick] {
        let lines = raw.components(separatedBy: .newlines)
        
        var bricks = [Brick]()
        for (index, line) in lines.enumerated() {
            let startC = line.split(separator: "~")[0]
            let start = Coordinate3D(x: Int(startC.split(separator: ",")[0])!, y: Int(startC.split(separator: ",")[1])!, z: Int(startC.split(separator: ",")[2])!)
            
            let endC = line.split(separator: "~")[1]
            let end = Coordinate3D(x: Int(endC.split(separator: ",")[0])!, y: Int(endC.split(separator: ",")[1])!, z: Int(endC.split(separator: ",")[2])!)
            
            bricks.append(Brick(id: index, start: start, end: end))
        }
        return bricks
    }
    
    typealias Input = [Brick]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day22 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let sortedByZ = input.sorted { min($0.start.z, $0.end.z) < min($1.start.z, $1.end.z) }
        
        let fallenBricks = try letBricksFall(bricks: sortedByZ)
        
        var checkDisintegration = [Brick]()
        var safeDisintegrations = 0
        
        for index in fallenBricks.indices {
            checkDisintegration = fallenBricks
            checkDisintegration.remove(at: index)
            
            let disintegrated = try letBricksFall(bricks: checkDisintegration)
            if disintegrated == checkDisintegration {
                safeDisintegrations += 1
            }
        }
        
        return safeDisintegrations
    }
    
    private static func letBricksFall(bricks: [Brick]) throws -> [Brick] {
        var fallenBricks = [Brick]()
        
        for (currentBrickIndex, currentBrick) in bricks.enumerated() {
            if !bricks.indices.contains(currentBrickIndex) {
                break
            }
            
            var currentBrick = currentBrick
            
            if currentBrick.start.x == currentBrick.end.x && currentBrick.start.y == currentBrick.end.y {
                // brick is single line on z axis
                while min(currentBrick.start.z, currentBrick.end.z) > 1  && !fallenBricks.contains(where: {
                    max($0.start.z, $0.end.z) + 1 == min(currentBrick.start.z, currentBrick.end.z) && ($0.start.x...$0.end.x).contains(currentBrick.start.x) && ($0.start.y...$0.end.y).contains(currentBrick.start.y)
                }) {
                    currentBrick = Brick(id: currentBrick.id, start: Coordinate3D(x: currentBrick.start.x, y: currentBrick.start.y, z: currentBrick.start.z - 1), end: Coordinate3D(x: currentBrick.end.x, y: currentBrick.end.y, z: currentBrick.end.z - 1))
                }
            } else if currentBrick.start.x == currentBrick.end.x && currentBrick.start.z == currentBrick.end.z {
                // brick is single line on y axis
                while currentBrick.start.z > 1  && !fallenBricks.contains(where: {
                    max($0.start.z, $0.end.z) + 1 == currentBrick.start.z && ($0.start.x...$0.end.x).contains(currentBrick.start.x) && ($0.start.y...$0.end.y).contains { (currentBrick.start.y...currentBrick.end.y).contains($0) }
                }) {
                    currentBrick = Brick(id: currentBrick.id, start: Coordinate3D(x: currentBrick.start.x, y: currentBrick.start.y, z: currentBrick.start.z - 1), end: Coordinate3D(x: currentBrick.end.x, y: currentBrick.end.y, z: currentBrick.end.z - 1))
                }
            } else if currentBrick.start.y == currentBrick.end.y && currentBrick.start.z == currentBrick.end.z {
                // brick is single line on x axis
                while currentBrick.start.z > 1  && !fallenBricks.contains(where: {
                    max($0.start.z, $0.end.z) + 1 == currentBrick.start.z && ($0.start.x...$0.end.x).contains { (currentBrick.start.x...currentBrick.end.x).contains($0) } && ($0.start.y...$0.end.y).contains(currentBrick.start.y)
                }) {
                    currentBrick = Brick(id: currentBrick.id, start: Coordinate3D(x: currentBrick.start.x, y: currentBrick.start.y, z: currentBrick.start.z - 1), end: Coordinate3D(x: currentBrick.end.x, y: currentBrick.end.y, z: currentBrick.end.z - 1))
                }
            } else {
                throw ExecutionError.unsolvable
            }
            
            fallenBricks.append(currentBrick)
        }
        return fallenBricks
    }
}

// MARK: - PART 2

extension Day22 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let sortedByZ = input.sorted { min($0.start.z, $0.end.z) < min($1.start.z, $1.end.z) }
        
        let fallenBricks = try letBricksFall(bricks: sortedByZ)
        
        var checkDisintegration = [Brick]()
        var numberOfBricksThatFall = 0
        
        for index in fallenBricks.indices {
            checkDisintegration = fallenBricks
            checkDisintegration.remove(at: index)
            let checkDisintegrationSet = Set(checkDisintegration)
            
            let disintegratedSet = Set(try letBricksFall(bricks: checkDisintegration))
            let differences = checkDisintegrationSet.subtracting(disintegratedSet).count
            
            numberOfBricksThatFall += differences
        }
        
        return numberOfBricksThatFall
    }
}
