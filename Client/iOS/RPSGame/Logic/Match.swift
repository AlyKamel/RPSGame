

import Foundation

class Match: Decodable {
    let id: Int
    var duelcount: Int
    var players: [Player]?

    static func createMatch(gamecount: Int, player: Player, botMatch: Bool, callback: @escaping (Match?, MError?) -> ()) {
        URLConnection.createMatch(gamecount: gamecount, player: player, botMatch: botMatch) { data, err in
            guard err == nil else {
                callback(nil, err)
                return
            }
            
            let match = try! JSONDecoder().decode(Match.self, from: data!)
            callback(match, nil)
        }
    }
    
    static func join(matchid mid: Int, playerid pid: Int, callback: @escaping (Match?, MError?) -> Void) {
        URLConnection.joinMatch(matchID: mid, playerID: pid) { data, err in
            guard err == nil else {
                callback(nil, err)
                return
            }
            
            let match = try! JSONDecoder().decode(Match.self, from: data!)
            callback(match, nil)
        }
    }
    
    func setMove(player: Player, move: Move, callback: @escaping (MatchResult?, Int?, MError?) -> Void) {
        URLConnection.makeMove(matchID: id, playerID: player.id, move: move) { data, err in
            guard err == nil else {
                callback(nil, nil, err)
                return
            }

            guard
                let json = try? JSONSerialization.jsonObject(with: data!) as? [String: Any],
                let matchJSON = json["match"] as? [String: Any],
                let duelres = json["duelresult"] as? Int,
                let endres = json["endresult"] as? Int
            else {
                callback(nil, nil, MError(message: "Problem with parsing"))
                return
            }

            self.duelcount = matchJSON["duelcount"] as! Int
            
            let ps = matchJSON["players"] as! [[String: Any]]
            let psD = try! JSONSerialization.data(withJSONObject: ps)
            self.players = try! JSONDecoder().decode([Player].self, from: psD)
            
            let mymove = self.players!.first(where: {$0.id == player.id})!.move
            let omove = self.players!.first(where: {$0.id != player.id})!.move
            
            // TODO: server sends {m1, m2, res}
            let s_duelres: MatchResult
            switch(duelres) {
            case 0:
                s_duelres = .tie(mymove!)
            case 1:
                s_duelres = .win(mymove!, omove!)
            case -1:
                s_duelres = .loss(mymove!, omove!)
            default:
                callback(nil, nil, MError(message: "Problem with parsing"))
                return
            }
            
            if self.duelcount == 0 {
                callback(s_duelres, endres, nil)
            } else {
                callback(s_duelres, nil, nil)
            }
        }
    }
}



