//
//  Heap.swift
//
//  Advent of Code Tools
//
//  based on https://www.raywenderlich.com/586-swift-algorithm-club-heap-and-priority-queue-data-structure
//

public struct Heap<Element> where Element: Comparable {
    private var elements: [Element]
    private let comparator: (Element, Element) -> Bool

    public static func minHeap() -> Heap { Heap(comparator: <) }
    public static func maxHeap() -> Heap { Heap(comparator: >) }

    public init<S: Sequence>(elements: S,
                             comparator: @escaping (Element, Element) -> Bool) where S.Element == Element {
        self.init(comparator: comparator)
        elements.forEach {
            insert($0)
        }
    }

    public init(comparator: @escaping (Element, Element) -> Bool) {
        self.elements = []
        self.comparator = comparator
    }

    public var isEmpty: Bool { elements.isEmpty }

    public var count: Int { elements.count }

    public func peek() -> Element? { elements.first }

    public mutating func insert(_ element: Element) {
        elements.append(element)
        siftUp(elementAtIndex: count - 1)
    }

    public mutating func pop() -> Element? {
        guard !isEmpty else {
            return nil
        }

        elements.swapAt(0, count - 1)
        let element = elements.removeLast()
        if !isEmpty {
            siftDown(elementAtIndex: 0)
        }
        return element
    }

    private mutating func siftUp(elementAtIndex index: Int) {
        let parent = parentIndex(of: index)
        guard index > 0, comparator(elements[index], elements[parent]) else {
            return
        }

        elements.swapAt(index, parent)
        siftUp(elementAtIndex: parent)
    }

    private mutating func siftDown(elementAtIndex index: Int) {
        let childIndex = highestPriorityIndex(for: index)
        if index == childIndex {
            return
        }

        elements.swapAt(index, childIndex)
        siftDown(elementAtIndex: childIndex)
    }

    private func leftChildIndex(of index: Int) -> Int {
        (2 * index) + 1
    }

    private func rightChildIndex(of index: Int) -> Int {
        (2 * index) + 2
    }

    private func parentIndex(of index: Int) -> Int {
        (index - 1) / 2
    }

    private func highestPriorityIndex(of parentIndex: Int, and childIndex: Int) -> Int {
        guard childIndex < count, comparator(elements[childIndex], elements[parentIndex]) else {
            return parentIndex
        }

        return childIndex
    }

    private func highestPriorityIndex(for parent: Int) -> Int {
        highestPriorityIndex(of: highestPriorityIndex(of: parent, and: leftChildIndex(of: parent)),
                             and: rightChildIndex(of: parent))
    }
}
