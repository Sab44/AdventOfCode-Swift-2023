//
//  Day08.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

struct Network: Parsable {
    struct Node {
        let id: String
        let left: String
        let right: String
    }
    
    let directions: [Character]
    let nodes: [Node]
    
    static func parse(raw: String) throws -> Network {
        let lines = raw.components(separatedBy: .newlines)
        
        let directions: [Character] = Array(lines[0])
        
        var nodes: [Node] = []
        lines.dropFirst(2).forEach { line in
            nodes.append(Node(id: String(line.prefix(3)),
                              left: String(line.split(separator: ", ")[0].suffix(3)),
                              right: String(line.split(separator: ", ")[1].prefix(3))))
        }
        
        return Network(directions: directions, nodes: nodes)
    }
}

@main
struct Day08: Puzzle {
    typealias Input = Network
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day08 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var currentDirectionIndex = 0

        var currentNode = "AAA"
        var steps = 0

        while currentNode != "ZZZ" {
            let direction = getNextDirection(input: input, currentIndex: &currentDirectionIndex)
            let node = input.nodes.first { $0.id == currentNode }!

            if direction == "R" {
                currentNode = node.right
            } else {
                currentNode = node.left
            }

            steps += 1
        }

        return steps
    }
}

extension Day08 {
    static func getNextDirection(input: Input, currentIndex: inout Int) -> Character {
        if input.directions.indices.contains(currentIndex) {
            let direction = input.directions[currentIndex]
            currentIndex += 1
            return direction
        }

        currentIndex = 1
        return input.directions[0]
    }
}

// MARK: - PART 2

extension Day08 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        var currentDirectionIndex = 0

        var currentNodes: [(Network.Node, Network.Node)] = input.nodes.filter { $0.id.last == "A" }.map { ($0, $0) }
        let initialNodesCount = currentNodes.count

        var cycleLenghts: Set<Int> = []
        var stepsPerNode: [String: Int] = [:]

        while cycleLenghts.count < initialNodesCount {
            let direction = getNextDirection(input: input, currentIndex: &currentDirectionIndex)

            var nextNodes: [Network.Node] = []

            currentNodes.forEach { node in
                if direction == "R" {
                    nextNodes.append(input.nodes.first { $0.id == node.1.right }!)
                } else {
                    nextNodes.append(input.nodes.first { $0.id == node.1.left }!)
                }

                stepsPerNode[node.0.id] = stepsPerNode[node.0.id, default: 0] + 1
            }

            currentNodes = currentNodes.enumerated().map { index, nodePair in (nodePair.0, nextNodes[index]) }

            currentNodes.filter { $0.1.id.last == "Z" }.forEach { finishedNode in
                cycleLenghts.insert(stepsPerNode[finishedNode.0.id]!)
                currentNodes = currentNodes.filter { $0.0.id != finishedNode.0.id }
            }
        }

        return cycleLenghts.reduce(1, lcm)
    }
}
