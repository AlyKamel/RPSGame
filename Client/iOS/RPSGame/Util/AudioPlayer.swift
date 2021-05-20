//
//  AudioPlayer.swift
//  RPSGame
//
//  Created by Aly Kamel on 3/8/20.
//

import Foundation
import AVFoundation

class AudioPlayer {
    private static var avplayer: AVAudioPlayer?
    
    public static func playAudio(name: String) {
        do {
            guard let path = Bundle.main.path(forResource: name, ofType: "wav") else {
                throw MError(message: "")
            }
            
            avplayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            avplayer?.play()
        } catch {
            print("error loading sound")
        }
    }
}
