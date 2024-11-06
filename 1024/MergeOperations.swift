//
//  MergeOperations.swift
//  1024
//
//  Created by Daneo Van Overloop on 01/11/2024.
//

import Foundation

protocol MoveOperation {
    var axis: Axis { get }
    func calculateNextState(for: inout [Tile?])
}

enum Axis {
    case horizontal
    case vertical
}

struct MergeRightOperation: MoveOperation {
    var axis: Axis {
        .horizontal
    }

    func calculateNextState(for board: inout [Tile?]) {
        let iterator = BoardSequence(
            itemsPerAxis: board.itemsPerAxis,
            direction: .right
        )
        process(board: &board, iterator: iterator)
    }
}

struct MergeLeftOperation: MoveOperation {
    var axis: Axis {
        .horizontal
    }

    func calculateNextState(for board: inout [Tile?]) {
        let iterator = BoardSequence(
            itemsPerAxis: board.itemsPerAxis,
            direction: .left
        )
        process(board: &board, iterator: iterator)
    }
}

struct MergeDownOperation: MoveOperation {
    var axis: Axis {
        .vertical
    }

    func calculateNextState(for board: inout [Tile?]) {
        let iterator = BoardSequence(
            itemsPerAxis: board.itemsPerAxis,
            direction: .down
        )
        process(board: &board, iterator: iterator)
    }
}

struct MergeUpOperation: MoveOperation {
    var axis: Axis {
        .vertical
    }

    func calculateNextState(for board: inout [Tile?]) {
        let iterator = BoardSequence(
            itemsPerAxis: board.itemsPerAxis,
            direction: .up
        )
        process(board: &board, iterator: iterator)
    }
}

typealias BoardState = [Tile?]
struct BoardSequence: Sequence, IteratorProtocol {
    private var values: [Coordinate] = []

    // FIXME: This shouldn't use the SwipeDirection
    init(itemsPerAxis: Int, direction: SwipeDirection) {
        let dimension = 0 ..< itemsPerAxis

        switch direction {
        case .left:
            // [(0,3), (0,2), (0,1), (0,0), ...]
            values = dimension
                .reduce(into: [(Int, Int)]()) { arr, row in
                    let columns = dimension.reversed()
                    let indices = columns.map { (row, $0) }
                    arr += indices
                }
        case .right:
            // [(0,0), (0,1), (0,2), (0,3), ...]
            values = dimension
                .reduce(into: [(Int, Int)]()) { arr, row in
                    let columns = dimension
                    let indices = columns.map { (row, $0) }
                    arr += indices
                }
        case .down:
            // [(0,0), (1,0), (2,0), ... ]
            values = dimension
                .reduce(into: [(Int, Int)]()) { arr, column in
                    let rows = dimension
                    let indices = rows.map { ($0, column) }
                    arr += indices
                }
        case .up:
            // [(3,0), (2,0), (1,0), (0,0), (3,1), ...]
            values = dimension
                .reduce(into: [(Int, Int)]()) { arr, column in
                    let rows = dimension.reversed()
                    let indices = rows.map { ($0, column) }
                    arr += indices
                }
        }
    }

    mutating func next() -> (Int, Int)? {
        guard !values.isEmpty else {
            return nil
        }

        return values.removeFirst()
    }
}

private extension [Coordinate] {
    mutating func sort(by axis: Axis) {
        sort { coordinate1, coordinate2 in
            switch axis {
            case .horizontal:
                return coordinate1.row < coordinate2.row
            case .vertical:
                return coordinate1.column < coordinate2.column
            }
        }
    }
}

extension MoveOperation {
    private func isOnSameAxis(variable: Coordinate?, reference: Coordinate) -> Bool {
        switch axis {
        case .horizontal:
            return reference.row == variable?.row
        case .vertical:
            return reference.column == variable?.column
        }
    }

    // 1. If 2 tiles next to each other have the same value and were not previously merged, merge them
    // 2. If 2 tiles are merged, and there's an empty tile between them, move the tile to the empty position
    // 3.
    func process(
        board: inout [Tile?],
        iterator: BoardSequence
    ) {
        var lastTilePosition: Coordinate?
        var emptyPositions: [Coordinate] = []

        for current in iterator.reversed() {
            var position: Coordinate = current

            // If we've switched either column or row, reset the references
            if !isOnSameAxis(variable: lastTilePosition, reference: position) {
                lastTilePosition = nil
            }

            emptyPositions
                .removeAll(where: { !isOnSameAxis(variable: $0, reference: position) })
            emptyPositions.sort(by: axis)

            // Select the item currently under review
            guard let currentTile = board.item(at: position) else {
                emptyPositions.append(position)

                continue
            }

            // If we've encountered an empty spot before, move the tile there.
            if emptyPositions.count > 0 {
                let previouslyEmptyPosition = emptyPositions.removeFirst()

                board.remove(coordinate: position)
                board.update(
                    coordinate: previouslyEmptyPosition,
                    value: currentTile
                )

                emptyPositions.append(position)
                position = previouslyEmptyPosition
            }

            // If there's a tile under review, but no previously encountered tile, store its location and continue
            guard let previousCoordinate = lastTilePosition else {
                lastTilePosition = position

                continue
            }

            // Confirm both the current and previous tile have the same value and can be merged, otherwise continue
            guard
                let lastElement = board.item(at: previousCoordinate),
                currentTile.value == lastElement.value
            else {
                lastTilePosition = position
                continue
            }

            // Merge the 2 tiles, drop both and insert the new tile on the correct position
            let newTile = currentTile.merge(with: lastElement)
            board.remove(coordinate: previousCoordinate)
            board.remove(coordinate: position)

            board.update(
                coordinate: previousCoordinate,
                value: newTile
            )
            lastTilePosition = nil
            emptyPositions.insert(position, at: 0)
        }
    }
}

private typealias Coordinate = (row: Int, column: Int)
private typealias TrackedCoordinate = (index: Int, coordinate: Coordinate)

private extension [Tile?] {
    mutating func update(coordinate: Coordinate, value: Element) {
        let index = index(for: coordinate)

        guard index < count else {
            preconditionFailure("Something wrong in the calculation for item's position")
        }

        self[index] = value
    }

    mutating func remove(coordinate: Coordinate) {
        update(coordinate: coordinate, value: nil)
    }

    func item(at coordinate: Coordinate) -> Tile? {
        let index = index(for: coordinate)

        guard index < count else {
            preconditionFailure("Something wrong in the calculation for item's position")
        }

        return self[index]
    }

    private func index(for coordinate: Coordinate) -> Int {
        let (row, column) = coordinate
        return row * itemsPerAxis + column
    }
}
