//
//  MergeOperationsTests.swift
//  1024Tests
//
//  Created by Daneo Van Overloop on 01/11/2024.
//

@testable import _024
import Testing

struct MergeHorizontalOperationsTests {
    var operation: any MoveOperation = MergeRightOperation()

    @Test
    func mergesRightOn2by2() async throws {
        var board: [Tile?] = [
            Tile(value: 2), Tile(value: 2),
            Tile(value: 2), Tile(value: 2),
        ]

        let expected = [
            nil, Tile(value: 4),
            nil, Tile(value: 4),
        ]

        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergesRightAndAlignsToOuterEdge() async throws {
        var board: [Tile?] = [
            nil, Tile(value: 2), Tile(value: 2),
            nil, Tile(value: 2), Tile(value: 2),
            nil, Tile(value: 2), Tile(value: 2),
        ]

        let expected = [
            nil, nil, Tile(value: 4),
            nil, nil, Tile(value: 4),
            nil, nil, Tile(value: 4),
        ]

        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergesRightWithEmptyCellsAndAlignsToOuterEdges() async throws {
        var board: [Tile?] = [
            nil, Tile(value: 2), nil, Tile(value: 2),
            Tile(value: 2), nil, nil, Tile(value: 2),
            Tile(value: 2), nil, Tile(value: 2), nil,
            Tile(value: 2), nil, nil, Tile(value: 2),
        ]

        let expected = [
            nil, nil, nil, Tile(value: 4),
            nil, nil, nil, Tile(value: 4),
            nil, nil, nil, Tile(value: 4),
            nil, nil, nil, Tile(value: 4),
        ]

        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergesTwoOutOf3Tiles() {
        var board: [Tile?] = [
            Tile(value: 2), Tile(value: 2), Tile(value: 2),
            nil, nil, nil,
            nil, nil, nil,
            nil, nil, nil,
        ]

        operation.calculateNextState(for: &board)

        let expected = [
            nil, Tile(value: 2), Tile(value: 4),
            nil, nil, nil,
            nil, nil, nil,
            nil, nil, nil,
        ]

        #expect(expected.values == board.values)
    }

    @Test
    func mergesOnlyOneCombinationPerMove() {
        var board: [Tile?] = [
            Tile(value: 2), Tile(value: 2), Tile(value: 2), Tile(value: 2),
            nil, Tile(value: 4), Tile(value: 2), Tile(value: 2),
            nil, nil, nil, nil,
            nil, nil, nil, nil,
        ]

        let expected = [
            nil, nil, Tile(value: 4), Tile(value: 4),
            nil, nil, Tile(value: 4), Tile(value: 4),
            nil, nil, nil, nil,
            nil, nil, nil, nil,
        ]

        operation.calculateNextState(for: &board)
        #expect(expected.values == board.values)
    }

    @Test
    func mergesRightWithMultipleItems() {
        var board: [Tile?] = [
            nil, nil, Tile(value: 2), nil,
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 4), Tile(value: 2), Tile(value: 2), nil,
        ]

        let expected = [
            nil, nil, nil, Tile(value: 2),
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            nil, nil, Tile(value: 4), Tile(value: 4),
        ]

        operation.calculateNextState(for: &board)
        #expect(expected.values == board.values)
    }

    @Test
    mutating func mergesLeftCorrectly() async throws {
        var board: [Tile?] = Array(repeating: Tile(value: 2), count: 4)

        operation = MergeLeftOperation()
        operation.calculateNextState(for: &board)

        let expected = [
            Tile(value: 4), nil,
            Tile(value: 4), nil,
        ]
        #expect(board.values == expected.values)
    }

    @Test
    mutating func mergesLeftWithMultipleItems() async throws {
        var board: [Tile?] = [
            nil, nil, Tile(value: 2), Tile(value: 4),
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 2), nil, nil, nil,
        ]
        operation = MergeLeftOperation()
        operation.calculateNextState(for: &board)

        let expected = [
            Tile(value: 2), Tile(value: 4), nil, nil,
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 2), nil, nil, nil,
        ]
        #expect(board.values == expected.values)
    }
}

struct MergeVerticalOperationsTests {
    @Test
    func mergesUpwardsFor2by2() async throws {
        var board: [Tile?] = [
            Tile(value: 2), Tile(value: 2),
            Tile(value: 2), Tile(value: 2),
        ]

        let expected = [
            Tile(value: 4), Tile(value: 4),
            nil, nil,
        ]

        let operation = MergeUpOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergesDownwardsFor2by2() async throws {
        var board: [Tile?] = [
            Tile(value: 2), Tile(value: 2),
            Tile(value: 2), Tile(value: 2),
        ]

        let expected = [
            nil, nil,
            Tile(value: 4), Tile(value: 4),
        ]

        let operation = MergeDownOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergeDownwardsMovesTile() {
        var board: [Tile?] = [
            Tile(value: 4), nil, Tile(value: 2), nil,
            Tile(value: 2), nil, nil, nil,
            Tile(value: 4), nil, nil, nil,
            Tile(value: 2), nil, nil, nil,
        ]

        let expected = [
            Tile(value: 4), nil, nil, nil,
            Tile(value: 2), nil, nil, nil,
            Tile(value: 4), nil, nil, nil,
            Tile(value: 2), nil, Tile(value: 2), nil,
        ]

        let operation = MergeDownOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergeDownward() {
        var board: [Tile?] = [
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 2), nil, nil, nil,
            nil, Tile(value: 2), nil, nil,
        ]

        let expected = [
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 2), Tile(value: 2), nil, nil,
        ]

        let operation = MergeDownOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }
    
    @Test
    func mergeDownwardWithAnEmptyTileInBetween() {
        var board: [Tile?] = [
            nil, nil, Tile(value: 2), nil,
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            Tile(value: 4), Tile(value: 2), Tile(value: 4), nil
        ]

        let expected = [
            nil, nil, nil, nil,
            nil, nil, nil, nil,
            nil, nil, Tile(value: 2), nil,
            Tile(value: 4), Tile(value: 2), Tile(value: 4), nil
        ]

        let operation = MergeDownOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }

    @Test
    func mergeUpwardsCorrectly() {
        var board: [Tile?] = [
            Tile(value: 4), Tile(value: 2), Tile(value: 8), Tile(value: 2),
            Tile(value: 8), Tile(value: 4), nil, nil,
            nil, nil, nil, Tile(value: 2),
            nil, nil, nil, nil,
        ]

        let expected = [
            Tile(value: 4), Tile(value: 2), Tile(value: 8), Tile(value: 4),
            Tile(value: 8), Tile(value: 4), nil, nil,
            nil, nil, nil, nil,
            nil, nil, nil, nil,
        ]
        let operation = MergeUpOperation()
        operation.calculateNextState(for: &board)

        #expect(expected.values == board.values)
    }
}

private extension [Tile?] {
    var values: [UInt8?] {
        return map { $0?.value }
    }
}
