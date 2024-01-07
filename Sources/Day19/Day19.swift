//
//  Day19.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct PartSorting: Parsable {
    struct Workflow {
        let name: String
        let operations: [String]
    }
    
    struct Part: Hashable {
        let x: Int
        let m: Int
        let a: Int
        let s: Int
    }
   
    let worksflows: [Workflow]
    let parts: [Part]
    
    static func parse(raw: String) throws -> PartSorting {
        let lines = raw.components(separatedBy: .newlines)
        let emptyLineIndex = lines.firstIndex(of: "")!
        
        var workflows = [Workflow]()
        for wIndex in 0..<emptyLineIndex {
            let name = String(lines[wIndex].split(separator: "{")[0])
            let operations = lines[wIndex].split(separator: "{")[1].dropLast(1).components(separatedBy: ",")
            workflows.append(Workflow(name: name, operations: operations))
        }
        
        var parts = [Part]()
        for pIndex in (emptyLineIndex + 1)...lines.lastIndex {
            let components = lines[pIndex].components(separatedBy: ",")
            let part = Part(
                x: Int(components[0].dropFirst(1).split(separator: "=")[1])!,
                m: Int(components[1].split(separator: "=")[1])!,
                a: Int(components[2].split(separator: "=")[1])!,
                s: Int(components[3].dropLast(1).split(separator: "=")[1])!
            )
            parts.append(part)
        }
        
        return PartSorting(worksflows: workflows, parts: parts)
    }
}

@main
struct Day19: Puzzle {
    typealias Input = PartSorting
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day19 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var parts = [PartSorting.Part: String]()
        var accepted = [PartSorting.Part]()
        
        for part in input.parts {
            parts[part] = "in"
            
            while parts[part] != "A" && parts[part] != "R" {
                let currentFlow = input.worksflows.first { $0.name == parts[part] }!
                for operation in currentFlow.operations {
                    if operation.contains("<") {
                        let left = operation.split(separator: "<")[0].first!
                        let right = Int(operation.split(separator: "<")[1].split(separator: ":")[0])!
                        let next = operation.split(separator: "<")[1].split(separator: ":")[1]
                        
                        if left == "x" && part.x < right {
                            parts[part] = String(next)
                            break
                        } else if left == "m" && part.m < right {
                            parts[part] = String(next)
                            break
                        } else if left == "a" && part.a < right {
                            parts[part] = String(next)
                            break
                        } else if left == "s" && part.s < right {
                            parts[part] = String(next)
                            break
                        }
                    }
                    
                    if operation.contains(">") {
                        let left = operation.split(separator: ">")[0].first!
                        let right = Int(operation.split(separator: ">")[1].split(separator: ":")[0])!
                        let next = operation.split(separator: ">")[1].split(separator: ":")[1]
                        
                        if left == "x" && part.x > right {
                            parts[part] = String(next)
                            break
                        } else if left == "m" && part.m > right {
                            parts[part] = String(next)
                            break
                        } else if left == "a" && part.a > right {
                            parts[part] = String(next)
                            break
                        } else if left == "s" && part.s > right {
                            parts[part] = String(next)
                            break
                        }
                    }
                    
                    parts[part] = operation
                }
            }
            
            if parts[part] == "A" {
                accepted.append(part)
            }
        }
        
        return accepted.map { $0.x + $0.m + $0.a + $0.s }.sum()
    }
}

// MARK: - PART 2

extension Day19 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
