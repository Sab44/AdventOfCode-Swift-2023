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
        /**
         * Say the rock we want to throw to smash all the hailstones starts out at
         * xR, yR, zR, dxR, dyR, dzR, but we don't actually know what any of those
         * values is. We can start "simply" by identifying where on each axis
         * and when as time (t) the rock should collide with one hailstone
         * (with properties of, say: x, y, z, dx, dy, dz) as:
         *
         *      xR + (t * dxR) = x + (t * dx)
         *      yR + (t * dyR) = y + (t * dy)
         *      zR + (t * dzR) = z + (t * dz)
         *
         * Rearranging to solve for `t`, we get:
         *
         *      t = (xR - x)/(dx - dxR) = (yR - y)/(dy - dyR) = (zR - z)/(dz - dzR).
         *
         * For _just_ two axes (start with X/Y again), we can isolate the
         * values related to just the rock (which won't change from one hailstone
         * to another in order to solve the puzzle) by rearranging the relationship
         * between the X and Y axes like so:
         *
         *      (xR - x)/(dx - dxR) = (yR - y)/(dy - dyR)
         *      (xR - x)(dy - dyR)  = (yR - y)(dx - dxR)
         *      xR*dy - x*dy - xR*dyR + x*dyR = yR*dx - yR*dxR - y*dx + y*dxR
         *      yR*dxR - xR*dyR = yR*dx - y*dx + y*dxR - xR*dy + x*dy - x*dyR
         *
         * Because the terms (yR*dxR - xR*dyR) should be the same no matter which
         * hailstone we consider (in order to hit all the hailstones), we can
         * alternatively consider another hailstone with properties of, say:
         * x', y', z', dx', dy', dz', like so:
         *
         *      yR*dxR - xR*dyR = yR*dx' - y'*dx' + y'*dxR - xR*dy' + x'*dy' - x'*dyR
         *
         * Because (yR*dxR - xR*dyR) is unchanging, it must be true that:
         *
         *      yR*dx - y*dx + y*dxR - xR*dy + x*dy - x*dyR = yR*dx' - y'*dx' + y'*dxR - xR*dy' + x'*dy' - x'*dyR
         *      (dy'-dy)xR + (dx - dx')yR + (y - y')dxR + (x' - x)dyR = y*dx - x*dy -y'*dx' + x'dy'
         *
         * Since we need to solve for the properties of the rock, we can substitute
         * the actual values from any pair of hailstones into this equation. We'll
         * need at least four pairs of hailstones to solve for the four unknowns.
         *
         * We can perform the same rearrangement for the X and Z axes like so:
         *
         *      (xR - x)/(dx - dxR) = (zR - z)/(dz - dzR)
         *      (xR - x)(dz - dzR)  = (zR - z)(dx - dxR)
         *      xR*dz - x*dz - xR*dzR + x*dzR = zR*dx - zR*dxR - z*dx + z*dxR
         *      zR*dxR - xR*dzR = zR*dx  -  z*dx  + z*dxR  - xR*dz  + x*dz   - x*dzR
         *                      = zR*dx' - z'*dx' + z'*dxR - xR*dz' + x'*dz' - x'*dzR
         *      zR*dx - z*dx + z*dxR - xR*dz + x*dz  - x*dzR = zR*dx' - z'*dx' + z'*dxR - xR*dz' + x'*dz' - x'*dzR
         *      (dz'-dz)xR + (dx - dx')zR + (z - z')dxR + (x' - x)dzR = z*dx - x*dz -z'*dx' + x'dz'
         *
         * The neat thing is, if we already know xR and dxR from solving the first set
         * of equations, then we only have two unknowns remaining (zR and dzR), for
         * which we only need two pairs of hailstones by rearranging the system of
         * equations like:
         *
         *       (dx - dx')zR + (x' - x)dzR = z*dx - x*dz -z'*dx' + x'dz' - (dz'-dz)xR - (z - z')dxR
         */
        
        let windowedInput: [(Hail, Hail)] = Array(input.prefix(5)).paired()
        
        let gaussianInput: [[Int]] = windowedInput.map { h1, h2 in
            // This comes from:
            // (dy'-dy)xR + (dx - dx')yR + (y - y')dxR + (x' - x)dyR = y*dx - x*dy -y'*dx' + x'dy'
            let result: [Int] = [
                h2.velocity.y - h1.velocity.y, // (dy' - dy)
                h1.velocity.x - h2.velocity.x, // (dx - dx')
                h1.position.y - h2.position.y, // (y - y')
                h2.position.x - h1.position.x, // (x' - x')
                // This is the right-hand side of the equation, or
                // y*dx - x*dy -y'*dx' + x'dy'
                ((h1.position.y * h1.velocity.x) + (-h1.position.x * h1.velocity.y) + (-h2.position.y * h2.velocity.x) + (h2.position.x * h2.velocity.y))
            ]
            
            return result
        }
        
        let solved: [Int] = try gaussianElimination(coefficients: gaussianInput)
        let (rockX, rockY, rockDX) = (solved[0], solved[1], solved[2])
        
        let windowedInputZ : [(Hail, Hail)] = Array(input.prefix(3)).paired()
        
        let gaussianInputZ: [[Int]] = windowedInputZ.map { h1, h2 in
            let result: [Int] = [
                // This comes from:
                // (dx - dx')zR + (x' - x)dzR = z*dx - x*dz -z'*dx' + x'dz' - (dz'-dz)xR - (z - z')dxR
                h1.velocity.x - h2.velocity.x,  // (dx - dx')
                h2.position.x - h1.position.x,    // (x' - x)

                // This is the right-hand side again
                //  z*dx - x*dz - z'*dx' + x'dz' - (dz'-dz)xR - (z - z')dxR
                ( (h1.position.z  * h1.velocity.x)                  // z*dx
                - (h1.position.x  * h1.velocity.z)                  // x*dz
                - (h2.position.z  * h2.velocity.x)                  // z'*dx'
                + (h2.position.x  * h2.velocity.z)                  // x'*dz'
                - ((h2.velocity.z - h1.velocity.z) * rockX)         // (dz'-dz)xR
                - ((h1.position.z  - h2.position.z)  * rockDX))     // (z - z')dxR
            ]
            
            return result
        }
        
        let solvedZ: [Int] = try gaussianElimination(coefficients: gaussianInputZ)
        let rockZ = solvedZ[0]
        
        return Int(rockX + rockY + rockZ)
    }
    
    
    /**
     * Solve a system of linear equations using Gaussian Elimination
     *
     * Yep, this comes from Wikipedia too. Specifically:
     * https://en.wikipedia.org/wiki/Gaussian_elimination. As I understand it, this
     * works by converting a system of linear equation into a simpler series of
     * equations.
     *
     * For the example, solving for the X, Y, dX, and dY components, the matrix
     * of coefficients is simplified like so:
     *
     *  [[-2, -1, -6, -1,  -44],     >     [[1, 0, 0, 0, 24],   (X)
     *   [-1,  1, -6,  2,    9],     >      [0, 1, 0, 0, 13],   (Y)
     *   [ 0,  1, -6, -8,   -3],     >      [0, 0, 1, 0, -3],   (dX)
     *   [-3, -2, 12,  8, -126]]     >      [0, 0, 0, 1,  1]]   (dY)
     *
     * This is called the "reduced row echelon" form, and achieving this state means
     * that our constants on the right-hand side of the equation _is_ the value for
     * the unknown variable, like:
     *
     *    -2X - 1Y -  6dX - 1dY =  -44  ->  1X + 0Y + 0dX + 0dY = 24  ->  X = 24
     *    -1X + 1Y -  6dX + 2dY =    9  ->  0X + 1Y + 0dX + 0dY = 13  ->  Y = 13
     *     0X + 1Y -  6dX - 8dY =   -3  ->  0X + 0Y + 1dX + 0dY = -3  -> dX = -3
     *    -3X - 2Y + 12dX + 8dY = -126  ->  0X + 0Y + 0dX + 1dY =  1  -> dy =  1
     *
     * @param coefficients The coefficients of the system of linear equations.
     * @return The coefficients on the right-hand side of the simplified system
     * of equations.
     */
    private static func gaussianElimination(coefficients: [[Int]]) throws -> [Int] {
        var coefficients = coefficients.map { $0.map { Double($0) } }
        let rows = coefficients.count
        let cols = coefficients[0].count
        
        // This only works on a square matrix (with one extra column for the
        // coefficient on the right-hand side of the equation).
        guard rows == cols - 1 else {
            throw ExecutionError.unsolvable
        }
        
        // We operate on each row in the matrix of coefficients.
        for row in coefficients.indices {
            // Normalize the row starting with the diagonal value of each row.
            let pivot = coefficients[row][row]
            for col in coefficients[row].indices {
                coefficients[row][col] /= pivot
            }
            
            // Sweep the other rows with `row`
            for otherRow in coefficients.indices {
                if row == otherRow { continue }
                
                let factor = coefficients[otherRow][row]
                for col in coefficients[otherRow].indices {
                    coefficients[otherRow][col] -= factor * coefficients[row][col]
                }
            }
        }
        
        return coefficients.compactMap { $0.last }.map { Int($0.rounded()) }
    }
}

fileprivate extension Array {
    func paired() -> [(Element, Element)] {
        var pairs: [(Element, Element)] = []
        var index = startIndex
        
        while index < endIndex {
            let end = index + 2
            let pair = Array(self[index..<Swift.min(end, endIndex)])
            if pair.count == 2 {
                pairs.append((pair[0], pair[1]))
            }
            index += 1
        }
        
        return pairs
    }
}
