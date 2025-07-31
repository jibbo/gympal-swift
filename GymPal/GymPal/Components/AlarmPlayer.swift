//
//  AlarmPlayer.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 14/07/25.
//

import AVFoundation

class AlarmPlayer: NSObject, AVAudioPlayerDelegate {
    private var player: AVAudioPlayer?

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound file not found: \(name)")
            return
        }
        do {
            let session = AVAudioSession.sharedInstance()
//            try session.setCategory(.playback, options: [.duckOthers]) // lowers volume of other audio sources
            try session.setCategory(.playback) // stops and resumes other features
            try session.setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        player?.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
