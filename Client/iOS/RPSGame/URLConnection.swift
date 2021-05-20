import Foundation

struct MError: Decodable, Error {
    let message: String
}

class URLConnection {
    private static let baseurl = URL(string: "https://rps-game-server.herokuapp.com/")!
    
    static func createPlayer(name: String, completion: @escaping (Data?, MError?) -> Void) {
        postRequest(path: "start", json: ["name": name]){ data, status, err in
            guard err == nil, let data = data else {
                completion(nil, MError(message: "Server error"))
                return
            }

            completion(data, nil)
        }
    }
    
    static func createMatch(gamecount: Int, player: Player, botMatch: Bool, completion: @escaping (Data?, MError?) -> Void) {
        postRequest(path: "matches", json: ["gamecount": gamecount, "playerId": player.id, "botMatch": botMatch]){ data, status, err in
            guard err == nil, let data = data else {
                completion(nil, MError(message: "Server error"))
                return
            }

            completion(data, nil)
        }
    }
    
    static func joinMatch(matchID: Int, playerID: Int, completion: @escaping (Data?, MError?) -> Void) {
        let path = "matches/\(matchID)/players/\(playerID)"
        postRequest(path: path, json: nil){ data, status, err in
            guard err == nil, let data = data else {
                completion(nil, MError(message: "Server error"))
                return
            }
            
            guard status != 400 else {
                let merror = try! JSONDecoder().decode(MError.self, from: data)
                completion(nil, merror)
                return
            }

            completion(data, nil)
        }
    }
    
    static func makeMove(matchID: Int, playerID: Int, move: Move, completion: @escaping (Data?, MError?) -> Void) {
        let path = "matches/\(matchID)/players/\(playerID)/play"
        let moveJSON = ["move": move.rawValue]
        postRequest(path: path, json: moveJSON){ data, status, err in
            guard err == nil, let data = data else {
                completion(nil, MError(message: "Server error"))
                return
            }
            
            guard status != 400 else {
                let merror = try! JSONDecoder().decode(MError.self, from: data)
                completion(nil, merror)
                return
            }
            
            completion(data, nil)
        }
    }
    
//    static func makeMove_upload(matchID: Int, playerID: Int, move: Move, completion: @escaping (Data?, MError?) -> Void) {
//        var request = createRequest(path: "path")
//        request.httpMethod = "POST"
//        
//        
//        let boundary = "Boundary-\(NSUUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        let body = NSMutableData();
//        let filename = "\.jpg"
//        let mimetype = "image/jpg"
//
//        body.append(makeStringAppend(string: "--\(boundary)\r\n")!)
//        body.append(makeStringAppend(string: "Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")!)
//        body.append(makeStringAppend(string: "Content-Type: \(mimetype)\r\n\r\n")!)
//        body.append(imageDataKey as Data)
//        body.append(makeStringAppend(string: "\r\n")!)
//        body.append(makeStringAppend(string: "--\(boundary)--\r\n")!)
//        
//        request.httpBody = body
//        
//        URLSession.shared.dataTask(with: request) { data, resp, err in
//            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
//            callback(data, status, err)
//        }.resume()
//    }
    
    private static func makeStringAppend(string: String) -> Data? {
        return string.data(using: String.Encoding.utf8, allowLossyConversion: true)
    }
    
    static func deleteData(playerID: Int, matchID: Int){
        let json = ["playerId": playerID, "matchId": matchID]
        postRequest(path: "deleteme", json: json){ _, _, _ in }
    }
    
    private static func postRequest(path: String, json: [String: Any]?, callback: @escaping (Data?, Int, Error?) -> Void) {
        var request = createRequest(path: path)
        request.httpMethod = "POST"
        
        if let json = json {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        }
        
        URLSession.shared.dataTask(with: request) { data, resp, err in
            let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
            callback(data, status, err)
        }.resume()
    }
    
    private static func createRequest(path: String) -> URLRequest {
        let url = baseurl.appendingPathComponent(path)
        return URLRequest(url: url)
    }
}

