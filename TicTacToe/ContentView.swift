//
//  ContentView.swift
//  TicTacToe
//
//  Created by Akhilesh Mishra on 18/06/21.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                
                LazyVGrid(columns: viewModel.columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        ZStack {
                            GameboardCircleView(geometry: geometry)
                            
                            MoveIndicatorView(systemImageName: viewModel.moves[i]?.indicator ?? "")
                        }
                        .onTapGesture {
                            viewModel.processPlayerMove(for: i)
                        }
                    }
                }
                
                Spacer()
            }
            .disabled(viewModel.isGameboardDisabled)
            .alert(item: $viewModel.alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: { viewModel.resetGame() }))
            })
            .padding()
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


enum Player {
    case human, computer
}

struct Move {
    let player: Player
    let boardIndex: Int
    
    var indicator: String {
        return player == .human ? "xmark" : "circle"
    }
}

struct GameboardCircleView: View {
    
    var geometry: GeometryProxy
    
    var body: some View {
        Circle()
            .foregroundColor(.red)
            .opacity(0.5)
            .frame(width: geometry.size.width/3 - 15,
                   height: geometry.size.width/3 - 15)
    }
}

struct MoveIndicatorView: View {
    
    var systemImageName: String
    
    var body: some View {
        Image(systemName: systemImageName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.white)
    }
}
