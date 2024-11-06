//
//  GameState.swift
//  1024
//
//  Created by Daneo Van Overloop on 15/09/2024.
//

import Foundation

enum SwipeDirection {
    case right
    case left

    case down
    case up
}

class GameState: ObservableObject {
    let score = 0

    private(set) var boardState: [Tile?]

    private let numberOfTiles: Int
    private var numberGenerator: RandomNumberGenerator
    private var numberOfElements: Int {
        boardState.count
    }

    init(
        numberOfTiles: Int = 16,
        boardState: [Tile?]? = nil,
        numberGenerator: RandomNumberGenerator? = nil
    ) {
        let startState = (0 ..< numberOfTiles).map { _ -> Tile? in
            nil
        }
        let generator = numberGenerator ?? SeededGenerator(seed: UInt64.random(in: 0 ..< UInt64.max))

        self.numberOfTiles = numberOfTiles
        self.boardState = boardState ?? startState
        self.numberGenerator = generator

        guard self.boardState.contains(where: { $0 != nil }) else {
            let index = randomTile(generator: &self.numberGenerator)
            self.boardState[index] = Tile(value: 2)
            return
        }
    }

    func reset() {
        let startTileIndex = randomTile(generator: &numberGenerator)

        boardState = (0 ..< numberOfTiles).map { index in
            guard index == startTileIndex else {
                return nil
            }
            return Tile(value: 2)
        }

        objectWillChange.send()
    }

    func apply(operation: MoveOperation) {
        print("Merging: \(operation.axis)")
        print("Before: \(boardState.map { $0?.value })")
        operation.calculateNextState(for: &boardState)
        print("After: \(boardState.map { $0?.value })")
        let position = randomTile(generator: &numberGenerator)
        boardState[position] = Tile(value: 2)

        objectWillChange.send()
    }

    private func randomTile(generator: inout RandomNumberGenerator) -> Int {
        let possiblePositions = 0 ..< numberOfElements
        var nextTile: Int

        repeat {
            nextTile = Int.random(in: possiblePositions, using: &generator)
        } while boardState[nextTile] != nil

        return nextTile
    }
}

extension GameState {
    var itemsPerAxis: Int {
        return boardState.itemsPerAxis
    }
}

extension [Tile?] {
    var itemsPerAxis: Int {
        return Int(sqrt(Double(count)))
    }
}

class SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    func next() -> UInt64 {
        print("Seed: \(state)")
        state = state &* 6_364_136_223_846_793_005 &+ 1
        return state
    }
}
