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
    
    func flipped() -> FlipFlop {
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
    
    func updatedInputs(pulse: Pulse) -> Conjunction {
        var inputStates = inputs
        inputStates[activeInput] = pulse
        return Conjunction(name: name,
                           destinations: destinations,
                           inputs: inputStates,
                           activeInput: "")
    }
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
            let inputs = modules.filter { $0.destinations.contains(conjModule.name) }
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
        var modules = input
        
        var lowCount = 0
        var highCount = 0
        
        for _ in 0..<1000 {
            lowCount += 1
            
            let (addLows, addHighs) = try pushButtonAndCountPulses(modules: &modules)
            lowCount += addLows
            highCount += addHighs
        }
        
        return lowCount * highCount
    }
    
    private static func pushButtonAndCountPulses(modules: inout [Module]) throws -> (Int, Int) {
        let broadcaster = modules.first { $0.name == "broadcaster" }!
        
        var queue = Deque<(Module, Pulse)>()
        queue.append((broadcaster, .low))
        
        var lowCount = 0
        var highCount = 0
        
        while !queue.isEmpty {
            let (currentModule, currentPulse) = queue.popFirst()!
            
            switch currentModule {
            case is Broadcaster:
                currentModule.destinations.map { destination in
                    let destModule = modules.first { $0.name == destination }!
                    return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                }.forEach {
                    queue.append(($0, .low))
                    lowCount += 1
                }
            case let flipFlop as FlipFlop:
                if currentPulse == .low {
                    let index = modules.firstIndex { $0.name == flipFlop.name }!
                    modules[index] = flipFlop.flipped()
                    
                    let pulse: Pulse = flipFlop.state ? .low : .high
                    
                    currentModule.destinations.map { destination in
                        let destModule = modules.first { $0.name == destination }!
                        return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                    }.forEach {
                        queue.append(($0, pulse))
                        if pulse == .low {
                            lowCount += 1
                        } else {
                            highCount += 1
                        }
                    }
                }
            case let conjunction as Conjunction:
                let updatedModule = conjunction.updatedInputs(pulse: currentPulse)
                let index = modules.firstIndex { $0.name == conjunction.name }!
                modules[index] = updatedModule
                
                let pulse: Pulse = updatedModule.inputs.values.allSatisfy { $0 == .high } ? .low : .high
                
                currentModule.destinations.map { destination in
                    let destModule = modules.first { $0.name == destination }
                    return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                }.forEach {
                    if let validDest = $0 {
                        queue.append((validDest, pulse))
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
        
        return (lowCount, highCount)
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
        let rxInput = input.first { $0.destinations.contains("rx") }!
        let rxInputInputs = input.filter { $0.destinations.contains(rxInput.name) }.map { $0.name}
        
        var modules = input
        var cycleLengths = [Int]()
        
        for moduleName in rxInputInputs {
            let cycle = try findConjunctionCycleLength(modules: &modules, monitorModuleName: moduleName)
            cycleLengths.append(cycle)
            modules = input
        }
        
        for i in 0...3 {
            print(rxInputInputs[i])
            print(cycleLengths[i])
        }
        return cycleLengths.reduce(1, lcm)
    }
    
    private static func findConjunctionCycleLength(modules: inout Input,
                                                   monitorModuleName: String) throws -> Int {
        var presses = 1
        while (try !pushTheButton(modules: &modules, monitorModuleName: monitorModuleName)) {
            presses += 1
        }
        
        return presses
    }
    
    private static func pushTheButton(modules: inout Input,
                                      monitorModuleName: String) throws -> Bool {
        let broadcaster = modules.first { $0.name == "broadcaster" }!
        
        var queue = Deque<(Module, Pulse)>()
        queue.append((broadcaster, .low))
        
        var cycleFound = false
        
        while !queue.isEmpty {
            let (currentModule, currentPulse) = queue.popFirst()!
            
            switch currentModule {
            case is Broadcaster:
                currentModule.destinations.map { destination in
                    let destModule = modules.first { $0.name == destination }!
                    return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                }.forEach {
                    queue.append(($0, .low))
                }
            case let flipFlop as FlipFlop:
                if currentPulse == .low {
                    let index = modules.firstIndex { $0.name == flipFlop.name }!
                    modules[index] = flipFlop.flipped()
                    
                    let pulse: Pulse = flipFlop.state ? .low : .high
                    
                    currentModule.destinations.map { destination in
                        let destModule = modules.first { $0.name == destination }!
                        return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                    }.forEach {
                        queue.append(($0, pulse))
                    }
                }
            case let conjunction as Conjunction:
                let updatedModule = conjunction.updatedInputs(pulse: currentPulse)
                let index = modules.firstIndex { $0.name == conjunction.name }!
                modules[index] = updatedModule
                
                let pulse: Pulse = updatedModule.inputs.values.allSatisfy { $0 == .high } ? .low : .high
                if currentModule.name == monitorModuleName && pulse == .high {
                    cycleFound = true
                }
                
                currentModule.destinations.compactMap { destination in
                    let destModule = modules.first { $0.name == destination }
                    return getIfConjunction(module: destModule, currentModuleName: currentModule.name) ?? destModule
                }.forEach {
                    queue.append(($0, pulse))
                }
            default:
                throw ExecutionError.unsolvable
            }
        }
        
        return cycleFound
    }
}
