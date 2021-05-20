//
//  EndPage.swift
//  RPSGame
//
//  Created by Aly Kamel on 28/5/20.
//

import SwiftUI

struct EndPage: View {
    @ObservedObject var model: PageModel
    
    var body: some View {
        VStack {
            Text(model.result?.message ?? "")
            Button("Go to start screen"){
                self.model.state = .Start
            }
            //TODO Restart match
        }
        .onAppear(perform: playSound)
        //.onDisappear(perform: self.avplayer?.stop) // TODO check
    }
    
    func playSound(){
        let soundname: String
        switch self.model.result {
        case .win:
            soundname = "cheers"
        case .loss:
            soundname = "boos"
        case .tie:
            soundname = "hmm"
        case nil:
            return
        }
        
        AudioPlayer.playAudio(name: soundname)
    }
}

struct EndPage_Previews: PreviewProvider {
    static var previews: some View {
        EndPage(model: PageModel())
    }
}
