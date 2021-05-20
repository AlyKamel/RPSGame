

import SwiftUI

/// Represents a single move with an image of its type
struct BasicMoveView {
    let move: Move
    let image: Image
    
    /// - Parameter move: move to be represented
    init(_ move: Move){
        self.move = move
        image = Image("hand_\(move)")
            .renderingMode(.template)
    }
}

/// Represents a single move with an image of its type that is highlighted according to a result
struct MoveView: View {
    let basicView: BasicMoveView
    let result: MatchResult?
    
    /// - Parameter move: move to be represented
    /// - Parameter result: sets move highlight
    init (move: Move, result: MatchResult?) {
        basicView = BasicMoveView(move)
        self.result = result
    }
    
    var color: Color {
        switch(result){
        case .win(basicView.move, _):
            return .green
        case .loss(basicView.move, _):
            return .red
        case .tie(basicView.move):
            return .orange
        default:
            return .black
        }
    }
    
    var body: some View {
        basicView.image.resizable().scaledToFit().foregroundColor(color)
    }
}

struct MoveView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Move.allCases, id: \.self) { move in
            HStack {
                MoveView(move: move, result: nil)
                MoveView(move: move, result: .win(move, move))
                MoveView(move: move, result: .loss(move, move))
                MoveView(move: move, result: .tie(move))
            }
        }
        .previewLayout(.fixed(width: 450, height: 150))
    }
}
