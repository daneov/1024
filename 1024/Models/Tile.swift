//
//  Tile.swift
//  1024
//
//  Created by Daneo Van Overloop on 02/11/2024.
//

import Foundation

struct Tile: Identifiable, Equatable {
    let id = UUID()

    var value: UInt8

    func merge(with tile: Tile) -> Tile {
        return Tile(value: value + tile.value)
    }
}
