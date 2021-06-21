//
//  ContentView.swift
//  TicTacToe
//
//  Created by Akhilesh Mishra on 18/06/21.
//

import SwiftUI

struct ContentView: View {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @State private var moves: [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameboardDisabled = false
    @State private var alertItem: AlertItem?
    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(width: geometry.size.width/3 - 15,
                                       height: geometry.size.width/3 - 15)
                            
                            Image(systemName: moves[i]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if isPositionOcuupied(in: moves, for: i) { return }
                            moves[i] = Move(player: .human, boardIndex: i)
                            
                            //Check for win or draw condition
                            if checkForWinCondition(for: .human, in: moves) {
                                alertItem = AlertContext.humanWins
                                return
                            }
                            
                            if checkForDraw(in: moves) {
                                alertItem = AlertContext.gameDraw
                                return
                            }
                            
                            isGameboardDisabled = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                let computerPosition = determineComputerPosition(in: moves)
                                moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
                                isGameboardDisabled = false
                                
                                if checkForWinCondition(for: .computer, in: moves) {
                                    alertItem = AlertContext.computerWins
                                    return
                                }
                                
                                if checkForDraw(in: moves) {
                                    alertItem = AlertContext.gameDraw
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .disabled(isGameboardDisabled)
            .alert(item: $alertItem, content: { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: .default(alertItem.buttonTitle, action: { resetGame() }))
            })
            .padding()
        })
    }
    
    func isPositionOcuupied(in move: [Move?], for index: Int) -> Bool {
        return moves.contains(where: { $0?.boardIndex == index })
    }
    
    func determineComputerPosition(in moves: [Move?]) -> Int {
        
        //If AI can win, then win
        let winPattern: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let computerMoves = moves.compactMap { $0 }.filter { $0.player == .computer }
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        
        for pattern in winPattern {
            let winPositions = pattern.subtracting(computerPositions)
            if winPositions.count == 1 {
                let isAvailable = !isPositionOcuupied(in: moves, for: winPositions.first!)
                if isAvailable { return winPositions.first! }
            }
        }
        
        //If AI can't win, then block
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == .human }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPattern {
            let humanWinPositions = pattern.subtracting(playerPositions)
            
            if humanWinPositions.count == 1 {
                let isAvailable = !isPositionOcuupied(in: moves, for: humanWinPositions.first!)
                if isAvailable { return humanWinPositions.first! }
            }
        }
        
        
        //If AI can't block, then take middle square
        if !isPositionOcuupied(in: moves, for: 4) {
            return 4
        }
        
        //If AI can't take middle square, then take random sqaure
        var computerPosition = Int.random(in: 0..<9)
        while (isPositionOcuupied(in: moves, for: computerPosition)) {
            computerPosition = Int.random(in: 0..<9)
        }
        
        return computerPosition
    }
    
    func checkForWinCondition(for player: Player, in moves: [Move?]) -> Bool {
        let winPattern: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        let playerMoves = moves.compactMap { $0 }.filter { $0.player == player }
        let playerPositions = Set(playerMoves.map { $0.boardIndex })
        
        for pattern in winPattern where pattern.isSubset(of: playerPositions) { return true }
        
        return false
    }
    
    func checkForDraw(in moves: [Move?]) -> Bool {
        return moves.compactMap { $0 }.count == 9
    }
    
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
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
