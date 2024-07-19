//
//  Day16.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Beam: Hashable {
    let x: Int
    let y: Int
    
    let direction: Direction
    
    func canMoveLeft(input: [[Character]]) -> Bool {
        return input[0].indices.contains(x - 1)
    }
    
    func canMoveUp(input: [[Character]]) -> Bool {
        return input.indices.contains(y - 1)
    }
    
    func canMoveRight(input: [[Character]]) -> Bool {
        return input[0].indices.contains(x + 1)
    }
    
    func canMoveDown(input: [[Character]]) -> Bool {
        return input.indices.contains(y + 1)
    }
}

@main
struct Day16: Puzzle {
    typealias Input = [[Character]]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day16 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var startDirection = Direction.right
        let start = input[0][0]
        guard start != "/" else {
            return 1
        }
        
        if start == "\\" {
            startDirection = .down
        }
        
        let startBeam = Beam(x: 0, y: 0, direction: startDirection)
        
        return findEnergizedTiles(input: input, startBeam: startBeam)
    }
}

extension Day16 {
    private static func findEnergizedTiles(input: Input, startBeam: Beam) -> Int {
        var beams = [startBeam]
        var energizedTiles: Set<Beam> = []
        
        while !beams.isEmpty {
            var newBeams: [Beam] = []
            for beam in beams {
                switch beam.direction {
                case .left:
                    guard beam.canMoveLeft(input: input) && !energizedTiles.contains(beam) else {
                        energizedTiles.insert(beam)
                        continue
                    }
                    energizedTiles.insert(beam)
                    
                    var newDirection = Direction.left
                    let left = input[beam.y][beam.x - 1]
                    if left == "/" {
                        newDirection = .down
                    } else if left == "\\" {
                        newDirection = .up
                    } else if left == "|" {
                        newDirection = .up
                        let additionalBeam = Beam(x: beam.x - 1, y: beam.y, direction: .down)
                        if !energizedTiles.contains(additionalBeam) {
                            newBeams.append(additionalBeam)
                        }
                    }
                    let newBeam = Beam(x: beam.x - 1, y: beam.y, direction: newDirection)
                    newBeams.append(newBeam)
                case .up:
                    guard beam.canMoveUp(input: input) && !energizedTiles.contains(beam) else {
                        energizedTiles.insert(beam)
                        continue
                    }
                    energizedTiles.insert(beam)
                    
                    var newDirection = Direction.up
                    let up = input[beam.y - 1][beam.x]
                    if up == "/" {
                        newDirection = .right
                    } else if up == "\\" {
                        newDirection = .left
                    } else if up == "-" {
                        newDirection = .left
                        let additionalBeam = Beam(x: beam.x, y: beam.y - 1, direction: .right)
                        if !energizedTiles.contains(additionalBeam) {
                            newBeams.append(additionalBeam)
                        }
                    }
                    let newBeam = Beam(x: beam.x, y: beam.y - 1, direction: newDirection)
                    newBeams.append(newBeam)
                case .right:
                    guard beam.canMoveRight(input: input) && !energizedTiles.contains(beam) else {
                        energizedTiles.insert(beam)
                        continue
                    }
                    energizedTiles.insert(beam)
                    
                    var newDirection = Direction.right
                    let right = input[beam.y][beam.x + 1]
                    if right == "/" {
                        newDirection = .up
                    } else if right == "\\" {
                        newDirection = .down
                    } else if right == "|" {
                        newDirection = .down
                        let additionalBeam = Beam(x: beam.x + 1, y: beam.y, direction: .up)
                        if !energizedTiles.contains(additionalBeam) {
                            newBeams.append(additionalBeam)
                        }
                    }
                    let newBeam = Beam(x: beam.x + 1, y: beam.y, direction: newDirection)
                    newBeams.append(newBeam)
                default:
                    guard beam.canMoveDown(input: input) && !energizedTiles.contains(beam) else {
                        energizedTiles.insert(beam)
                        continue
                    }
                    energizedTiles.insert(beam)
                    
                    var newDirection = Direction.down
                    let down = input[beam.y + 1][beam.x]
                    if down == "/" {
                        newDirection = .left
                    } else if down == "\\" {
                        newDirection = .right
                    } else if down == "-" {
                        newDirection = .right
                        let additionalBeam = Beam(x: beam.x, y: beam.y + 1, direction: .left)
                        if !energizedTiles.contains(additionalBeam) {
                            newBeams.append(additionalBeam)
                        }
                    }
                    let newBeam = Beam(x: beam.x, y: beam.y + 1, direction: newDirection)
                    newBeams.append(newBeam)
                }
            }
            beams = newBeams
        }
        
        let uniqueEnergizesTiles = Set(energizedTiles.map { Coordinate(x: $0.x, y: $0.y) })
        
        return uniqueEnergizesTiles.count
    }
}
// MARK: - PART 2

extension Day16 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var startBeams: [Beam] = []
        
        for i in input.indices {
            var additionalBeam: Beam? = nil
            var startDirection = Direction.right
            if input[i][0] == "/" {
                startDirection = .up
            } else if input[i][0] == "\\" {
                startDirection = .down
            } else if input[i][0] == "|" {
                startDirection = .down
                additionalBeam = Beam(x: 0, y: i, direction: .up)
            }
            startBeams.append(Beam(x: 0, y: i, direction: startDirection))
            if let additionalBeam {
                startBeams.append(additionalBeam)
            }
        }
        
        for j in input[0].indices {
            var additionalBeam: Beam? = nil
            var startDirection = Direction.down
            if input[0][j] == "/" {
                startDirection = .left
            } else if input[0][j] == "\\" {
                startDirection = .right
            } else if input[0][j] == "-" {
                startDirection = .right
                additionalBeam = Beam(x: j, y: 0, direction: .left)
            }
            startBeams.append(Beam(x: j, y: 0, direction: startDirection))
            if let additionalBeam {
                startBeams.append(additionalBeam)
            }
        }
        
        for i in input.indices {
            var additionalBeam: Beam? = nil
            var startDirection = Direction.left
            if input[i][input[i].lastIndex] == "/" {
                startDirection = .down
            } else if input[i][input[i].lastIndex] == "\\" {
                startDirection = .up
            } else if input[i][input[i].lastIndex] == "|" {
                startDirection = .up
                additionalBeam = Beam(x: input[i].lastIndex, y: i, direction: .down)
            }
            startBeams.append(Beam(x: input[i].lastIndex, y: i, direction: startDirection))
            if let additionalBeam {
                startBeams.append(additionalBeam)
            }
        }
        
        for j in input[0].indices {
            var additionalBeam: Beam? = nil
            var startDirection = Direction.up
            if input[input.lastIndex][j] == "/" {
                startDirection = .right
            } else if input[input.lastIndex][j] == "\\" {
                startDirection = .left
            } else if input[input.lastIndex][j] == "-" {
                startDirection = .left
                additionalBeam = Beam(x: j, y: input.lastIndex, direction: .right)
            }
            startBeams.append(Beam(x: j, y: input.lastIndex, direction: startDirection))
            if let additionalBeam {
                startBeams.append(additionalBeam)
            }
        }
        
        var maxEnergizedTiles = 0
        
        for startBeam in startBeams {
            let energizedTiles = findEnergizedTiles(input: input, startBeam: startBeam)
            maxEnergizedTiles = max(maxEnergizedTiles, energizedTiles)
        }
        
        return maxEnergizedTiles
    }
}
