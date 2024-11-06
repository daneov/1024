//
//  GameViewModel.swift
//  1024
//
//  Created by Daneo Van Overloop on 06/11/2024.
//

import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState = GameState(numberOfTiles: 25)
    
    var sideLength: Int {
        gameState.itemsPerAxis
    }
    
    func tile(at index: Int) -> String? {
        guard index < gameState.boardState.count else {
            preconditionFailure("Index is not within bounds. Configuration mistake?")
        }
        
        guard let tile = gameState.boardState[index] else {
            return nil
        }
        
        
        return String(tile.value)
    }
    
    func perform(gesture: CGSize) {
        if gesture.width < -100 {
            gameState.apply(operation: MergeLeftOperation())
        } else if gesture.width > 100 {
            gameState.apply(operation: MergeRightOperation())
        } else if gesture.height < 100 {
            gameState.apply(operation: MergeUpOperation())
        } else if gesture.height > 100 {
            gameState.apply(operation: MergeDownOperation())
        }
    }
    
    func reset() {
        gameState.reset()
    }
    
    var objectWillChange: ObservableObjectPublisher {
        gameState.objectWillChange
    }
}
