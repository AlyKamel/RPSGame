//
//  MatchResult.swift
//  RPSGame
//
//  Created by Aly Kamel on 14/5/20.
//

enum MatchResult {
    case win(Move, Move), loss(Move, Move), tie(Move)
    
    var message: String {
        switch(self){
        case .win(_, _):
            return "You won"
        case .loss(_, _):
            return "You lost"
        case .tie(_):
            return "You tied"
        }
    }
    
    static func getMatchResult(m1: Move, m2: Move) -> MatchResult {
        if m1 == m2 {
            return .tie(m1)
        }
        
        let hasWon: Bool = {
            switch(m1){
            case .rock:
                return m2 == .scissors
            case .paper:
                return m2 == .rock
            case .scissors:
                return m2 == .paper
            }
        }()

        return hasWon ? .win(m1, m2) : .loss(m1, m2)
    }
    
    func switchResult() -> MatchResult {
        switch(self){
        case let .win(m1, m2):
            return .loss(m2, m1)
        case let .loss(m1, m2):
            return .win(m2, m1)
        case .tie(_):
            return self
        }
    }
    
    func getPlayerMove() -> Move {
        switch(self){
        case .win(let m, _):
            return m
        case .loss(let m, _):
            return m
        case .tie(let m):
            return m
        }
    }
    
    func getOpponentMove() -> Move {
        self.switchResult().getPlayerMove()
    }
}
