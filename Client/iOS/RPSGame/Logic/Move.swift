//
//  Move.swift
//  RPSGame
//
//  Created by Aly Kamel on 14/5/20.
//

import SwiftUI


enum Move: Int, CaseIterable, Decodable {
    case rock = 0, paper, scissors
    
    static func getRandomMove() -> Move {
        return Move.allCases.randomElement()!
    }
}
