

import SwiftUI

struct ResultView: View {
    let result: MatchResult?
    let game_counter: (win: Int, loss: Int, tie: Int)
    
    var body: some View {
        VStack {
            Text(resultText)
                .font(.subheadline)
            Text("Won: \(game_counter.win) | Lost: \(game_counter.loss) | Tied: \(game_counter.tie)")
                .font(.subheadline)
        }
    }
    
    var resultText: String {
        result?.message ?? "Select a move"
    }
}

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ResultView(result: .win(.rock, .rock), game_counter: (1,0,0))
            ResultView(result: .loss(.rock, .rock), game_counter: (0,1,0))
            ResultView(result: .tie(.rock), game_counter: (0,0,1))
            ResultView(result: nil, game_counter: (0,0,0))
        }
        .previewLayout(.fixed(width: 200, height: 80))
    }
}
