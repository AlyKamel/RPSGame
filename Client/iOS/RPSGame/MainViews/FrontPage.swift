

import SwiftUI

struct FrontPage: View {
    @ObservedObject var model: PageModel
    
    /// Responsible to set an alert whenever an error occurs during the start of the game
    @State private var alertVisible = false
    @State private var alertMessage = "Error"
    
    /// Player name entry field
    @ObservedObject var nameInput = TextBindingManager()
    
    var body: some View {
        VStack {
            // Title
            HStack {
                ForEach(Move.allCases, id: \.self) { move in
                    BasicMoveView(move).image
                }
            }

            Text("RPSGAME").font(.largeTitle).fontWeight(.bold)

            
            // Name entry
            TextField("Enter your name", text: $nameInput.text)
                .border(Color.black)
                .frame(width: 180)
            
            Text("Welcome\(nameInput.text.isEmpty ? "!" : ", \(nameInput.text)!")")


            // Match setup
            MatchCreatorView(){ gamecount, botMatch in
                self.createPlayer() {
                    self.model.player!.createMatch(gamecount: gamecount, botMatch: botMatch){ err in
                        self.tryStartGame(err: err)
                    }
                }
            }.offset(y: 100)

            
            MatchJoinerView() { matchIdInput in
                guard let matchId = Int(matchIdInput), matchId >= 0 else {
                    self.setAlert(message: "Invalid matchid input")
                    return
                }
                
                self.createPlayer() {
                    self.model.player!.joinMatch(matchId){ err in
                        self.tryStartGame(err: err)
                    }
                }
            }.offset(y: 100)
            
        }.padding()
        .alert(isPresented: self.$alertVisible) {
            Alert(title: Text("Error"), message: Text(self.alertMessage))
        }
    }
    
    /// Transitions into game mode if no error has occured, otherwise sets an error alert
    /// - Parameter err: possible error that could halt the start of the game
    private func tryStartGame(err: MError?) {
        if let err = err {
            self.setAlert(message: err.message)
        } else {
            self.model.state = .Game
        }
    }
    
    private func setAlert(message: String) {
        self.alertMessage = message
        self.alertVisible = true
    }
    
    /// Attempts to create a player, then calls the provided function
    /// - Parameter callback: function that makes use of the created player
    private func createPlayer(callback: @escaping () -> Void) {
        guard !nameInput.text.isEmpty else {
            self.setAlert(message: "Enter name first")
            return
        }
        
        Player.createPlayer(name: nameInput.text) { player, err in
            if let err = err {
                self.setAlert(message: err.message)
            } else {
                self.model.player = player!
                callback()
            }
        }
    }
}

struct MatchCreatorView: View {
    let createMatch: (Int, Bool) -> Void
    @State private var showCreationOptions = false
    @State private var duelCount: Int = -1
    
    var body: some View {
        HStack(spacing: 20) {
            Text("Best of: ")
            ForEach([1, 3, 10], id: \.self) { num in
                Button(String(num)) {
                    self.duelCount = num
                    self.showCreationOptions = true
                }
            }
        }.actionSheet(isPresented: self.$showCreationOptions) {
            ActionSheet(title: Text("Play against:"), buttons: [
                .default(Text("Player")) { self.createMatch(self.duelCount, false) },
                .default(Text("Bot")) { self.createMatch(self.duelCount, true) },
                .cancel()
            ])
        }
    }
}

struct MatchJoinerView: View {
    let joinMatch: (String) -> ()
    @State private var matchIdInput: String = ""
    
    var body: some View {
        HStack {
            TextField("matchId", text: $matchIdInput)
                .multilineTextAlignment(.center)
                .border(Color.black)
                .frame(width: 70)
            Button("Join match") {
                self.joinMatch(self.matchIdInput)
            }
        }
    }
}

class TextBindingManager: ObservableObject {
    @Published var text = "" {
        didSet {
            if text.count > 10 || text.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
                text = oldValue
            }
        }
    }
}

struct FrontPage_Previews: PreviewProvider {
    static var previews: some View {
        FrontPage(model: PageModel())
    }
}

