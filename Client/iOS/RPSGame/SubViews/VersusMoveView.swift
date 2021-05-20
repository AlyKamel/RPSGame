

import SwiftUI

struct VersusMoveView: View {
    let playerName: String
    let opponentName: String
    let result: MatchResult
    
    var body: some View {
        HStack (spacing: 20){
            VStack {
                Text(playerName)
                MoveView(move: self.result.getPlayerMove(), result: self.result)
                    .frame(width: 150, height: 150)
            }

            VStack {
                Text(opponentName)
                MoveView(move: self.result.getOpponentMove(), result: self.result.switchResult())
                    .frame(width: 150, height: 150)
            }
        }.onAppear(perform: {AudioPlayer.playAudio(name: self.soundName)})
    }
    
    var soundName: String {
        switch(result){
        case .win(.rock, _), .loss(_, .rock):
            return "rock-smash"
        case .win(.paper, _), .loss(_, .paper):
            return "paper-crumble"
        case .win(.scissors, _), .loss(_, .scissors):
            return "scissors-cutting-paper"
        case .tie(.rock):
            return "rock-pick"
        case .tie(.paper):
            return "paper-flip"
        case .tie(.scissors):
            return "scissors-click"
        }
    }
}

struct VersusMoveView_Previews: PreviewProvider {
    static var previews: some View {
        VersusMoveView(playerName: "p1prev", opponentName: "p2prev", result: .loss(.rock, .paper))
    }
}
