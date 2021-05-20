

import Foundation

class Player: Decodable {
    let id: Int
    var name: String
    var move: Move?
    private(set) var match: Match?
    
    static func createPlayer(name: String, callback: @escaping (Player?, MError?) -> ()) {
        URLConnection.createPlayer(name: name) { data, err in
            guard err == nil else {
                callback(nil, err)
                return
            }
            
            let player = try! JSONDecoder().decode(Player.self, from: data!)
            callback(player, nil)
        }
    }
    
    func createMatch(gamecount: Int, botMatch: Bool, configView: @escaping (MError?) -> ()) { // creates + joins
        Match.createMatch(gamecount: gamecount, player: self, botMatch: botMatch){ match, err in
            self.match = match
            configView(err)
        }
    }
    
    func joinMatch(_ matchid: Int, configView: @escaping (MError?) -> ()) {
        Match.join(matchid: matchid, playerid: id){ match, err in
            self.match = match
            configView(err)
        }
    }
    
    func makeMove(_ move: Move, configView: @escaping (MatchResult?, Int?, MError?) -> ()) {
        guard let m = match else {
            configView(nil, nil, MError(message: "No match joined"))
            return
        }
        
        m.setMove(player: self, move: move) { matchres, endres, err in
            configView(matchres, endres, err)
        }
    }
}
