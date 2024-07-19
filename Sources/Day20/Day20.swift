//
//  Day20.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

import Collections

// this solution was copy&pasted, unable to solve part 2
enum Pulse {
    case high, low
}

struct Message: CustomStringConvertible {
    let pulse: Pulse
    let from: String
    let destination: String

    var description: String {
        "\(from) -\(pulse)-> \(destination)"
    }
}

class CommunicationsModule {
    let name: String
    let destinations: [String]

    init(name: String, destinations: [String]) {
        self.name = name
        self.destinations = destinations
    }

    func receive(_ pulse: Pulse, from name: String) -> [Message] { [] }

    func reset() {}

    func send(_ pulse: Pulse) -> [Message] {
        destinations.map {
            Message(pulse: pulse, from: self.name, destination: $0)
        }
    }

    static func make(from string: String) -> CommunicationsModule {
        let parts = string.components(separatedBy: " -> ")
        let destinations = parts[1].components(separatedBy: ", ")

        switch parts[0].prefix(1) {
        case "%": return Flipflop(name: String(parts[0].dropFirst(1)), destinations: destinations)
        case "&": return Conjunction(name: String(parts[0].dropFirst(1)), destinations: destinations)
        default: return Broadcaster(name: parts[0], destinations: destinations)
        }
    }
}

final class Flipflop: CommunicationsModule {
    private var state: Bool = false

    override func reset() {
        state = false
    }

    override func receive(_ pulse: Pulse, from name: String) -> [Message] {
        if pulse == .high {
            return []
        }

        state.toggle()
        return send(state ? .high : .low)
    }
}

final class Conjunction: CommunicationsModule {
    private var inputs = [String: Pulse]()
    private(set) var triggered = false

    func addInput(_ name: String) {
        inputs[name] = .low
    }

    override func reset() {
        triggered = false
        inputs.keys.forEach {
            inputs[$0] = .low
        }
    }

    override func receive(_ pulse: Pulse, from name: String) -> [Message] {
        inputs[name] = pulse
        var pulse = Pulse.high
        if inputs.values.allSatisfy({ $0 == .high }) {
            pulse = .low
        }
        if !triggered {
            triggered = pulse == .high
        }
        return send(pulse)
    }
}

final class Broadcaster: CommunicationsModule {
    override func receive(_ pulse: Pulse, from name: String) -> [Message] {
        send(pulse)
    }
}

final class Output: CommunicationsModule {
    // drop all input pulses
}

@main
struct Day20: Puzzle {
    static func transform(raw: String) async throws -> [String: CommunicationsModule] {
        let lines = raw.components(separatedBy: .newlines)
        var rawModules = lines.map { CommunicationsModule.make(from: $0) }
        
        let conjunctions = rawModules.compactMap { $0 as? Conjunction }
        for con in conjunctions {
            for module in rawModules {
                if module.destinations.contains(con.name) {
                    con.addInput(module.name)
                }
            }
        }

        var modules = Dictionary(uniqueKeysWithValues: rawModules.map { ($0.name, $0) })
        for module in rawModules {
            for dest in module.destinations {
                if modules[dest] == nil {
                    modules[dest] = Output(name: dest, destinations: [])
                }
            }
        }
        
        return modules
    }
    
    typealias Input = [String: CommunicationsModule]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day20 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var modules = input
        modules.values.forEach { $0.reset() }
                let broadcaster = modules["broadcaster"]!

                var highCount = 0
                var lowCount = 0

                for _ in 0 ..< 1000 {
                    lowCount += 1
                    var messages = broadcaster.receive(.low, from: "btn")
                    lowCount += messages.count

                    while !messages.isEmpty {
                        var next = [Message]()
                        for msg in messages {
                            let msgs = modules[msg.destination]!.receive(msg.pulse, from: msg.from)
                            let high = msgs.filter { $0.pulse == .high }.count
                            highCount += high
                            lowCount += msgs.count - high
                            next.append(contentsOf: msgs)
                        }
                        messages = next
                    }
                }

                return highCount * lowCount
    }
}

// MARK: - PART 2

extension Day20 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var modules = input
        modules.values.forEach { $0.reset() }

                // find the input to rx
                let rxSender = modules.values.first { $0.destinations == ["rx"] }!

                // find its input conjunctions so we can monitor them
                let inputs = modules.values.filter { $0.destinations.contains(rxSender.name) }.compactMap { $0 as? Conjunction }
                var counts = [String: Int]()

                let broadcaster = modules["broadcaster"]!

                for presses in 1 ..< Int.max {
                    var messages = broadcaster.receive(.low, from: "btn")

                    while !messages.isEmpty {
                        var next = [Message]()
                        for msg in messages {
                            let msgs = modules[msg.destination]!.receive(msg.pulse, from: msg.from)
                            next.append(contentsOf: msgs)
                            for input in inputs {
                                if input.triggered && counts[input.name] == nil {
                                    counts[input.name] = presses
                                }
                            }
                        }
                        messages = next
                    }
                    if counts.count == inputs.count {
                        break
                    }
                }

                return counts.values.reduce(1, *)
    }
}
