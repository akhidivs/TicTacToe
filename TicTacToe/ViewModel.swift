//
//  ViewModel.swift
//  TicTacToe
//
//  Created by Akhilesh Mishra on 21/06/21.
//

import SwiftUI

final class ViewModel: ObservableObject {
    
    let columns: [GridItem] = [GridItem(.flexible()),
                               GridItem(.flexible()),
                               GridItem(.flexible())]
    
    @Published var moves: [Move?] = Array(repeating: nil, count: 9)
    @Published var isGameboardDisabled = false
    @Published var alertItem: AlertItem?
    
    private let winPattern: Set<Set<Int>> = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    
    func processPlayerMove(for position: Int) {
        
        print("Hurray.....")
        //Processing Human Move
        if isPositionOcuupied(in: moves, for: position) { return }
        moves[position] = Move(player: .human, boardIndex: position)
        
        if checkForWinCondition(for: .human, in: moves) {
            alertItem = AlertContext.humanWins
            return
        }
        
        if checkForDraw(in: moves) {
            alertItem = AlertContext.gameDraw
            return
        }
        
        isGameboardDisabled = true
        
        //Processing Computer Move
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            let computerPosition = determineComputerPosition(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            isGameboardDisabled = false
            
            if checkForWinCondition(for: .computer, in: moves) {
                alertItem = AlertContext.computerWins
                return
            }
            
            if checkForDraw(in: moves) {
                alertItem = AlertContext.gameDraw
                return
            }
        }
    }
    
    
    func isPositionOcuupied(in move: [Move?], for index: Int) -> Bool {
        return moves.contains(where: { $0?.boardIndex == index })
    }
    
    func determineComputerPosition(in moves: [Move?]) -> Int {
        
        //If AI can win, then win
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
