//
//  Day07.swift
//  AoC-Swift-Template
//

import Foundation

import AoC
import Common

fileprivate let cardValues: [Character] = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A"]

fileprivate extension Character {
    var value: Int {
        return cardValues.firstIndex(of: self)!
    }
    
    var valueWithJoker: Int {
        var newCardValues = cardValues
        let joker = newCardValues.remove(at: 9)
        newCardValues.insert(joker, at: 0)
        return newCardValues.firstIndex(of: self)!
    }
}

struct HandOfCards: Parsable {
    enum HandType: Int {
        case highCard
        case onePair
        case twoPair
        case three
        case fullHouse
        case four
        case five
    }
    
    let hand: [Character]
    let bid: Int
    let type: HandType
    
    static func parse(raw: String) throws -> HandOfCards {
        let hand: [Character] = Array(raw.split(separator: " ")[0])
        let bid = Int(raw.split(separator: " ")[1])!
        
        let handType: HandType
        
        switch Set(hand).count {
        case 5:
            handType = .highCard
        case 4:
            handType = .onePair
        case 3:
            // could be two pair or three of a kind
            let dictionary = hand.reduce(into: [Character: Int]()) { dict, card in
                dict[card] = dict[card, default: 0] + 1
            }
            if dictionary.values.allSatisfy({ $0 < 3 }) {
                handType = .twoPair
            } else {
                handType = .three
            }
        case 2:
            // could be full house or four of a kind
            let dictionary = hand.reduce(into: [Character: Int]()) { dict, card in
                dict[card] = dict[card, default: 0] + 1
            }
            if dictionary.values.allSatisfy({ $0 < 4 }) {
                handType = .fullHouse
            } else {
                handType = .four
            }
        default:
            handType = .five
        }
        
        return HandOfCards(hand: hand, bid: bid, type: handType)
    }
}

@main
struct Day07: Puzzle {
    typealias Input = [HandOfCards]
    typealias OutputPartOne = Int
    typealias OutputPartTwo = Int
}

// MARK: - PART 1

extension Day07 {
    static func solvePartOne(_ input: Input) async throws -> OutputPartOne {
        return calculateWinnings(input: input, withJoker: false)
    }
}

extension Day07 {
    private static func calculateWinnings(input: Input, withJoker: Bool) -> Int {
        let sortedHands = input.sorted {
            if $0.type != $1.type {
                return $0.type.rawValue < $1.type.rawValue
            }
            for cardIndex in 0..<5 {
                let firstHandValue = withJoker ? $0.hand[cardIndex].valueWithJoker : $0.hand[cardIndex].value
                let secondHandValue = withJoker ? $1.hand[cardIndex].valueWithJoker : $1.hand[cardIndex].value
                if firstHandValue != secondHandValue {
                    return firstHandValue < secondHandValue
                }
            }
            return false
        }
        
        var winnings: [Int] = []
        for index in sortedHands.indices {
            winnings.append((index + 1) * sortedHands[index].bid)
        }
        
        return winnings.sum()
    }
}

// MARK: - PART 2

extension Day07 {
    static func solvePartTwo(_ input: Input) async throws -> OutputPartTwo {
        let newHandsOfCards = input.map { handOfCards in
            if handOfCards.hand.contains("J") {
                let newHandType: HandOfCards.HandType
                
                switch Set(handOfCards.hand).count {
                case 5:
                    newHandType = .onePair
                case 4:
                    newHandType = .three
                case 3:
                    // could be full house or four of a kind
                    let dictionary = handOfCards.hand.reduce(into: [Character: Int]()) { dict, card in
                        dict[card] = dict[card, default: 0] + 1
                    }
                    if dictionary["J"] == 1 && dictionary.values.allSatisfy({ $0 < 3 }) {
                        newHandType = .fullHouse
                    } else {
                        newHandType = .four
                    }
                default:
                    newHandType = .five
                }
                return HandOfCards(hand: handOfCards.hand, bid: handOfCards.bid, type: newHandType)
            }
                
            return handOfCards
        }
        
        return calculateWinnings(input: newHandsOfCards, withJoker: true)
    }
}
