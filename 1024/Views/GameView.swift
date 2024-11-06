//
//  ContentView.swift
//  1024
//
//  Created by Daneo Van Overloop on 15/09/2024.
//

import SwiftUI

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    
    var dimension: [Int] {
        Array(0..<viewModel.sideLength)
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Grid {
                    ForEach(dimension, id: \.self) { rowIndex in
                        GridRow {
                            ForEach(dimension, id: \.self) { columnIndex in
                                let index = rowIndex * dimension.count + columnIndex
                                

                                if let tile = viewModel.tile(at: index) {
                                    ZStack {
                                        Color.green
                                        Text(tile)
                                    }
                                    .border(Color.red, width: 2)
                                } else {
                                    Color.teal
                                        .gridCellUnsizedAxes([.horizontal, .vertical])
                                    
                                }
                            }
                        }.frame(width: 50, height: 50)
                    }
                }
                Spacer()
            }
            .gesture(
                DragGesture(minimumDistance: 0.1, coordinateSpace: .local)
                    .onEnded { gesture in
                        viewModel.perform(gesture: gesture.translation)
                        
                    }
            )
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        withAnimation {
                            viewModel.reset()
                        }
                    }
                }
            })
        }
    }
}

#Preview {
    GameView()
}
