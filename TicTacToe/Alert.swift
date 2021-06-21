//
//  Alert.swift
//  TicTacToe
//
//  Created by Akhilesh Mishra on 19/06/21.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    var title: Text
    var message: Text
    var buttonTitle: Text
}

struct AlertContext {
    static let humanWins    = AlertItem(title: Text("You win!"),
                                     message: Text("Congrats! You beat the computer."),
                                     buttonTitle: Text("Hell Yeah!"))
    
    static let computerWins = AlertItem(title: Text("You lost!"),
                                     message: Text("Computer wins the game"),
                                     buttonTitle: Text("Rematch"))
    
    static let gameDraw     = AlertItem(title: Text("Game Draw!"),
                                     message: Text("Nobody won the game"),
                                     buttonTitle: Text("Try Again"))
}
