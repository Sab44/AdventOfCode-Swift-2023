//
//  Day20.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

import Collections

enum Pulse: String {
    case low
    case high
}

protocol Module {
    var name: String { get }
    var destinations: [String] { get }
}

struct Broadcaster: Module {
    let name: String
    let destinations: [String]
}

struct FlipFlop: Module {
    let name: String
    let destinations: [String]
    let state: Bool
    
    func flip() -> FlipFlop {
        return FlipFlop(name: name,
                        destinations: destinations,
                        state: !state)
    }
}

struct Conjunction: Module {
    let name: String
    let destinations: [String]
    let inputs: [String: Pulse]
    let activeInput: String
}

@main
struct Day20: Puzzle {
    static func transform(raw: String) async throws -> [Module] {
        let lines = raw.components(separatedBy: .newlines)
        var modules = [Module]()
        
        for line in lines {
            let type = line.split(separator: " ").first!
            let destinations = line.split(separator: ">")[1].split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            
            if type == "broadcaster" {
                modules.append(Broadcaster(name: "broadcaster", destinations: destinations))
            } else if type.first == "%" {
                modules.append(FlipFlop(name: String(type.dropFirst(1)), destinations: destinations, state: false))
            } else if type.first == "&" {
                modules.append(Conjunction(name: String(type.dropFirst(1)),
                                           destinations: destinations,
                                           inputs: [:],
                                           activeInput: ""))
            }
        }
        
        let conjModules = modules.compactMap { $0 as? Conjunction }
        for conjModule in conjModules {
            let inputs = modules.filter { !conjModules.map { $0.name }.contains($0.name) }
                .filter { $0.destinations.contains(conjModule.name) }
                .reduce(into: [String: Pulse]()) {
                    $0[$1.name] = Pulse.low
                }
            let index = modules.firstIndex { $0.name == conjModule.name }!
            modules[index] = Conjunction(name: conjModule.name,
                                         destinations: conjModule.destinations,
                                         inputs: inputs,
                                         activeInput: "")
        }
        
        return modules
    }
    
    typealias Input = [Module]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day20 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        let broadcaster = input.first { $0.name == "broadcaster" }!
        var modules = input
        var queue = Deque<(Module, Pulse)>()
        
        var lowCount = 0
        var highCount = 0
        
        for _ in 0..<1000 {
            queue.append((broadcaster, .low))
            lowCount += 1
            
            while !queue.isEmpty {
                let (currentModule, currentPulse) = queue.popFirst()!
                
                switch currentModule {
                case is Broadcaster:
                    for dest in currentModule.destinations {
                        let destModule = modules.first { $0.name == dest }!
                        if let conjDestModule = getIfConjunction(module: destModule, currentModuleName: currentModule.name) {
                            queue.append((conjDestModule, .low))
                        } else {
                            queue.append((destModule, .low))
                        }
                        
                        lowCount += 1
                    }
                case let flipFlop as FlipFlop:
                    if currentPulse == .low {
                        let pulse: Pulse = flipFlop.state ? .low : .high
                        let flipped = flipFlop.flip()
                        let index = modules.firstIndex { $0.name == currentModule.name }!
                        modules[index] = flipped
                        
                        for dest in currentModule.destinations {
                            let destModule = modules.first { $0.name == dest }!
                            if let conjDestModule = getIfConjunction(module: destModule, currentModuleName: currentModule.name) {
                                queue.append((conjDestModule, pulse))
                            } else {
                                queue.append((destModule, pulse))
                            }
                            if flipFlop.state {
                                lowCount += 1
                            } else {
                                highCount += 1
                            }
                        }
                    }
                case let conjunction as Conjunction:
                    var inputStates = conjunction.inputs
                    inputStates[conjunction.activeInput] = currentPulse
                    let newModule = Conjunction(name: currentModule.name,
                                                destinations: currentModule.destinations,
                                                inputs: inputStates,
                                                activeInput: "")
                    
                    let index = modules.firstIndex { $0.name == currentModule.name }!
                    modules[index] = newModule
                    
                    let pulse: Pulse = inputStates.values.allSatisfy { $0 == .high } ? .low : .high
                    
                    for dest in currentModule.destinations {
                        let destModule = modules.first { $0.name == dest }
                        if let conjDestModule = getIfConjunction(module: destModule, currentModuleName: currentModule.name) {
                            queue.append((conjDestModule, pulse))
                        } else if destModule != nil {
                            queue.append((destModule!, pulse))
                        }
                        if pulse == .low {
                            lowCount += 1
                        } else {
                            highCount += 1
                        }
                    }
                default:
                    throw ExecutionError.unsolvable
                }
            }
        }
        
        return lowCount * highCount
    }
    
    private static func getIfConjunction(module: Module?, currentModuleName: String) -> Conjunction? {
        if let conjModule = module as? Conjunction {
            return Conjunction(name: conjModule.name,
                               destinations: conjModule.destinations,
                               inputs: conjModule.inputs,
                               activeInput: currentModuleName)
        }
        return nil
    }
}

// MARK: - PART 2

extension Day20 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        // TODO: Solve part 2 :)
        throw ExecutionError.notSolved
    }
}
