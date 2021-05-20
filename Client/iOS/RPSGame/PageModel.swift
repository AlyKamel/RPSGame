//
//  PageModel.swift
//  RPSGame
//
//  Created by Aly Kamel on 28/5/20.
//

import SwiftUI
import Combine

class PageModel: ObservableObject {
    
    /// Represents current game state
    @Published var state = GameMode.Start
    
    @Published var player: Player?
    
    /// Represents current game state
    @Published var result: MatchResult?
}

/// Representation of the game state (start, middle, end)
enum GameMode {
    case Start, Game, End
}
