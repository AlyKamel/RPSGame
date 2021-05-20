//
//  PlayerMoveView.swift
//  RPSGame
//
//  Created by Aly Kamel on 7/6/20.
//

import SwiftUI

// TODO: disable select button while scrolling
struct PlayerMoveView: View {
    let player: Player
    @Binding var selMove: Move
    
    @State private var failedMoveAlertVisible = false
    @State private var alertMessage = "Unable to join match"
    
    /// This function gets executed whenever a player submits his move.
    /// # Notes: #
    /// argument: function to get executed, when an error occurs during move submission. Error message is passed as an argument.
    let action: (@escaping (String) -> Void) -> Void
    
    var body: some View {
        VStack {
            Text(player.name)
            
            Picker(selection: $selMove, label: EmptyView()) {
                ForEach(Move.allCases, id: \.self) { move in
                    BasicMoveView(move).image
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .frame(width: 40, height: 30, alignment: .center)
            .clipped()
            .scaleEffect(CGSize(width: 5, height: 5))
            .padding(.bottom, 80)
            .padding(.top, 80)
            .padding(.trailing, 40)
            
            
            Button("SELECT"){
                self.action() { message in
                    self.failedMoveAlertVisible = true
                    self.alertMessage = message
                }
            }
        }.alert(isPresented: self.$failedMoveAlertVisible) {
            Alert(title: Text("Error"), message: Text(alertMessage))
        }
    }
}

struct PlayerMoveView_Previews: PreviewProvider {
    @State private static var selMove = Move.rock

    static var previews: some View {
        let playerData = Data("""
        {
            "name": "p1prev",
            "id": 0
        }
        """.utf8)
        let player = try! JSONDecoder().decode(Player.self, from: playerData)
        return VStack {
            PlayerMoveView(player: player, selMove: $selMove){ _ in}
            //Text("selMove: " + "\(selMove)") // does not work
        }
    }
}
