

import SwiftUI

struct GameView: View {
    @ObservedObject var model: PageModel
    
    @State private var selMove = Move.rock
    @State private var result: MatchResult?
    @State private var endres: Int?
    @State private var game_counter = (win: 0, loss: 0, tie: 0)
    
    var gameover: Bool {
        return game_counter.win + game_counter.loss + game_counter.tie == model.player!.match?.duelcount
    }
    
    init (model: PageModel) {
        self.model = model
    }
    
    var body: some View {
        VStack (spacing: 50) {
            Text("RPS Game")
                .font(.title)
                .foregroundColor(Color.red)
            
            Text("matchID: \(self.model.player!.match!.id)")
                .font(.subheadline)
                .offset(y: -40)
                .padding(.bottom, -40)

            if self.result == nil { // player has to select his move
                PlayerMoveView(player: model.player!, selMove: $selMove) { setAlert in
                    self.model.player!.makeMove(self.selMove) { duelres, endres, err in
                        if let err = err {
                            setAlert(err.message)
                            return
                        }
                        
                        self.result = duelres
                        self.endres = endres
                        self.incGameCounter()
                    }
                }
            } else { // result should be displayed
                endVersus()
                VersusMoveView(playerName: self.model.player!.name,
                    opponentName: self.model.player!.match!.players!.first(where: {$0.id != self.model.player!.id})!.name,
                    result: result!)
            }

            ResultView(result: result, game_counter: game_counter)
        }
    }
    
    func incGameCounter() {
        switch result {
        case .win:
            self.game_counter.win += 1
        case .loss:
            self.game_counter.loss += 1
        case .tie:
            self.game_counter.tie += 1
        case .none:
            break
        }
    }
    
    func endVersus() -> EmptyView {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            if self.gameover {
//                self.endGame()
//            }
            if self.endres != nil {
                self.endGame()
            }
            self.result = nil
        }
        return EmptyView()
    }
        
    func endGame() {
        //game_counter.win - game_counter.loss
        switch (self.endres!.signum()) {
        case -1: model.result = .loss(.rock, .rock)
        case 1: model.result = .win(.rock, .rock)
        case 0: model.result = .tie(.rock)
        default: break // unreachable
        }
        
        // transition to end screen
        self.model.state = .End
    }
}

struct GameView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var result: MatchResult? = nil
        @State private var selMove = Move.rock
        
        var body: some View {
            let playerData = Data("{\"name\": \"p1prev\", \"id\": 0}".utf8)
            let player = try! JSONDecoder().decode(Player.self, from: playerData)
            
            return VStack (spacing: 50) {
                Text("RPS Game")
                    .font(.title)
                    .foregroundColor(Color.red)
                
                Text("matchID: 999")
                    .font(.subheadline)
                    .offset(y: -40)
                    .padding(.bottom, -40)
                
                if self.result == nil {
                    PlayerMoveView(player: player, selMove: $selMove) { _ in
                        self.result = .getMatchResult(m1: self.selMove, m2: .getRandomMove())
                    }
                } else {
                    showVersus()
                }
                
                ResultView(result: result, game_counter: (-1, -1, -1))
            }
        }
        
        func showVersus() -> VersusMoveView {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.result = nil
            }
            return VersusMoveView(playerName: "p1prev", opponentName: "p2prev", result: result!)
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
