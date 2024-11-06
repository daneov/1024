//
//  GameStateTests.swift
//  1024Tests
//
//  Created by Daneo Van Overloop on 15/09/2024.
//

@testable import _024
import XCTest

final class GameStateTests: XCTestCase {
    var gameState: GameState!

    override func setUp() {
        gameState = GameState(numberGenerator: SeededGenerator(seed: 0))
    }

    func testGameStateInitialisesWithTwoValuedTile() throws {
        let result = gameState.boardState
            .compactMap { $0 }
            .reduce(0) {
                $0 + $1.value
            }

        let nonZeroTiles = gameState.boardState
            .compactMap { $0 }
            .filter { tile in
                tile.value > 0
            }

        XCTAssertEqual(result, 2)
        XCTAssertEqual(nonZeroTiles.count, 1)
    }

    func testGameStateInitialisesWith16Tiles() throws {
        XCTAssertEqual(gameState.boardState.count, 16)
    }

    func testGamesWithSameSeedsAreEqual() {
        let game1 = GameState(numberGenerator: SeededGenerator(seed: 0))
            .boardState
            .map { $0?.value }
        let game2 = GameState(numberGenerator: SeededGenerator(seed: 0))
            .boardState
            .map { $0?.value }

        XCTAssertEqual(game1, game2)
    }

    func test2GamesWithDifferentSeedsAreNotEqual() {
        let game1 = GameState(numberGenerator: SeededGenerator(seed: 0))
        let game2 = GameState(numberGenerator: SeededGenerator(seed: 1))

        XCTAssertNotEqual(game1.boardState, game2.boardState)
    }

    func testResetGameInitialisesWithOneTile() {
        var gameState = GameState(numberGenerator: SeededGenerator(seed: 0))
        gameState.reset()

        let tileValue = gameState.boardState
            .compactMap { $0 }
            .reduce(0) { $0 + $1.value }
        let nonZeroTiles = gameState.boardState
            .compactMap { $0 }

        XCTAssertEqual(tileValue, 2)
        XCTAssertEqual(nonZeroTiles.count, 1)
    }

    func testResetGameInitialisesDifferentBoard() {
        let gameState = GameState(numberGenerator: SeededGenerator(seed: 0))
        let previousState = gameState.boardState
        gameState.reset()

        XCTAssertNotEqual(previousState, gameState.boardState)
    }

    func testSwipeToRightAddsNewTile() {
        let gameState = GameState(numberGenerator: SeededGenerator(seed: 0))

        gameState.apply(operation: MergeRightOperation())
        let totalValue = gameState.boardState
            .compactMap { $0 }
            .reduce(0) { $0 + $1.value }
        XCTAssertEqual(totalValue, 4)
    }

    func testSwipeToRightAddsTileInDifferentSpot() {
        class FixedPositionGenerator: RandomNumberGenerator {
            var options = [UInt.max, 3]
            func next() -> UInt64 {
                return UInt64(options.popLast() ?? 0)
            }
        }

        let gameState = GameState(numberGenerator: FixedPositionGenerator())

        let state = gameState.boardState
        gameState.apply(operation: MergeRightOperation())

        let secondState = gameState.boardState

        XCTAssertNotEqual(state, secondState)
        XCTAssertEqual(secondState.count(where: { $0 != nil }), 2)
    }

    func testSwipeRightAddsTileToMatchingTile() {
        var boardState: [Tile?] = Array(repeating: nil, count: 16)
        boardState[3] = Tile(value: 2)
        boardState[2] = Tile(value: 2)

        let gameState = GameState(
            numberOfTiles: 16,
            boardState: boardState,
            numberGenerator: SeededGenerator(seed: 0)
        )
        gameState.apply(operation: MergeRightOperation())

        XCTAssertEqual(gameState.boardState[3]?.value, 4)
    }
}
