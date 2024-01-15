//
//  Day19.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct PartSorting: Parsable {
    struct Workflow: Hashable {
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
                    
                    // no condition applied, set last workflow as next flow
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

struct SortingPath: Hashable {
    let currentFlow: PartSorting.Workflow
    let conditions: [String]
}

extension Day19 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let startNode = input.worksflows.first { $0.name == "in" }!
        var pathStack = Stack<SortingPath>()
        let startPath = SortingPath(currentFlow: startNode, conditions: [])
        pathStack.push(startPath)
        
        var allConditions = Set<[String]>()
        
        while !pathStack.isEmpty {
            let current = pathStack.pop()!
            let operation = current.currentFlow.operations.first!
            
            if operation.last == "R" && operation.count > 1 {
                // invert condition and continue
                let rejectCondition = invertCondition(String(operation.dropLast(2)))
                let nextWorkflow = PartSorting.Workflow(name: current.currentFlow.name,
                                                        operations: current.currentFlow.operations.filter { $0 != operation })
                pathStack.push(SortingPath(currentFlow: nextWorkflow, conditions: current.conditions.plus(rejectCondition)))
            }
            else if operation.last == "A" && operation.count > 1 {
                // finish for this operation and continue with next
                let condition = String(operation.dropLast(2))
                allConditions.insert(current.conditions.plus(condition))
                
                let invertedCondition = invertCondition(String(operation.dropLast(2)))
                let nextWorkflow = PartSorting.Workflow(name: current.currentFlow.name,
                                                        operations: current.currentFlow.operations.filter { $0 != operation })
                pathStack.push(SortingPath(currentFlow: nextWorkflow, conditions: current.conditions.plus(invertedCondition)))
            }
            else if operation == "A" {
                // path finished, insert conditions
                allConditions.insert(current.conditions)
            }
            else if operation == "R" {
                // do nothing
            }
            // fallback is neither A nor R
            else if !operation.contains(":") {
                let nextWorkflow = input.worksflows.first { $0.name == operation }!
                pathStack.push(SortingPath(currentFlow: nextWorkflow, conditions: current.conditions))
            }
            // operation continues to another node
            else {
                // 1) condition is met, go to next node
                let condition = String(operation.split(separator: ":")[0])
                let nextNode = String(operation.split(separator: ":")[1])
                let nextWorkflow = input.worksflows.first { $0.name == nextNode }!
                pathStack.push(SortingPath(currentFlow: nextWorkflow, conditions: current.conditions.plus(condition)))
                
                // 2) condition is not met, continue with current node
                let invertedCondition = invertCondition(String(operation.split(separator: ":")[0]))
                let adaptedWorkflow = PartSorting.Workflow(name: current.currentFlow.name,
                                                           operations: current.currentFlow.operations.filter { $0 != operation })
                pathStack.push(SortingPath(currentFlow: adaptedWorkflow, conditions: current.conditions.plus(invertedCondition)))
            }
        }
        
        var result = 0
        let xmas: [Character] = ["x", "m", "a", "s"]
        
        for conditionSequence in allConditions {
            let dict = conditionSequence.reduce(into: [Character: [String]]()) {
                $0[$1.first!] = $0[$1.first!, default: []].plus($1)
            }
            
            let upperLimit = 4001
            var possibleValues = [Character: Range<Int>]()
            for (key, value) in dict {
                let upperBound = value.filter { $0.contains("<") }.map { Int($0.split(separator: "<")[1])! }.min() ?? upperLimit
                let lowerBound = value.filter { $0.contains(">") }.map { Int($0.split(separator: ">")[1])! }.max() ?? 0
                if upperBound <= lowerBound {
                    throw ExecutionError.unsolvable
                }
                possibleValues[key] = (lowerBound + 1)..<upperBound
            }
            
            xmas.filter { !possibleValues.keys.contains($0) }.forEach {
                possibleValues[$0] = 1..<upperLimit
            }
            
            result = result + possibleValues.values.map { $0.upperBound - $0.lowerBound }.reduce(1, *)
        }
        
        return result
    }
    
    private static func invertCondition(_ condition: String) -> String {
        let invertedCondition: String
        if condition.contains("<") {
            let correctedNumber = Int(condition.split(separator: "<")[1])! - 1
            invertedCondition = String(condition.split(separator: "<")[0]) + ">" + String(correctedNumber)
        } else {
            let correctedNumber = Int(condition.split(separator: ">")[1])! + 1
            invertedCondition = String(condition.split(separator: ">")[0]) + "<" + String(correctedNumber)
        }
        return invertedCondition
    }
}
