//
//  Day25.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common
import Algorithms

struct WiringDiagram: Parsable {
    let id: String
    let connectedNodes: [String]

    static func parse(raw: String) throws -> WiringDiagram {
        let id = raw.components(separatedBy: ":")[0]
        let connectedNodes = raw.components(separatedBy: ": ")[1].components(separatedBy: " ")

        return WiringDiagram(id: id, connectedNodes: connectedNodes)
    }
}

struct Edge: Equatable, Hashable {
    let source: String
    let target: String
    
    static func ==(lhs: Edge, rhs: Edge) -> Bool {
        return (lhs.source == rhs.source && lhs.target == rhs.target) || (lhs.source == rhs.target && lhs.target == rhs.source)
    }
    
    func hash(into hasher: inout Hasher) {
        let sorted = [source, target].sorted()
        hasher.combine(sorted[0])
        hasher.combine(sorted[1])
    }
}

@main
struct Day25: Puzzle {
    typealias Input = [WiringDiagram]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Void
}

// MARK: - PART 1

extension Day25 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        var edges = [Edge]()
        var vertices = Set<String>()
        
        for diagram in input {
            vertices.insert(diagram.id)
            for node in diagram.connectedNodes {
                edges.append(Edge(source: diagram.id, target: node))
                vertices.insert(node)
            }
        }
        
        var result = 0
        while true {
            let (minCut, groups) = kargerMinCut(vertices: vertices, edges: edges)
            if minCut == 3 {
                result = groups[0].split(separator: ", ").count * groups[1].split(separator: ", ").count
                break
            }
        }

        return result
    }
    
    // Karger's algorithm
    private static func kargerMinCut(vertices: Set<String>, edges: [Edge]) -> (Int, [String]) {
        var vertices = vertices
        var edges = edges
        
        // Begin Karger's while loop.
        while vertices.count > 2 {
            let edgeToRemove = edges.randomElement()!
            let sourceVertex = edgeToRemove.source
            let targetVertex = edgeToRemove.target
            
            // Merge the two vertices connected by the edge into one.
            let mergedVertex = "\(sourceVertex), \(targetVertex)"
            vertices.remove(targetVertex)
            vertices.remove(sourceVertex)
            vertices.insert(mergedVertex)
            
            edges = edges.compactMap { edge in
                if edge == edgeToRemove {
                    return nil
                } else if edge.target == targetVertex || edge.target == sourceVertex {
                    return Edge(source: edge.source, target: mergedVertex)
                } else if edge.source == sourceVertex || edge.source == targetVertex {
                    return Edge(source: mergedVertex, target: edge.target)
                } else {
                    return edge
                }
            }
        }
        
        return (edges.count, Array(vertices))
    }
}

// MARK: No Part 2 ; Merry Christmas!

extension Day25 {
    static func solvePartTwo(_ input: Input) async throws -> Void {}
}
