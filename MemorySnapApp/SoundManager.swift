//
//  soundManager.swift
//  MemorySnapApp
//
//  Created by H Coleman on 30/12/2020.
//

import Foundation
import AVFoundation

class SoundManager {
    
    var audioPlayer:AVPlayer?
    
    enum SoundEffect {
        
        case flip
        case match
        case nomatch
        case shuffle
    }
    
    func playSound(effect:SoundEffect) {
        
        var soundFilename = ""
        
        
        switch effect {
        
            case .flip:
                soundFilename = "cardflip"
                
            case .match:
                soundFilename = "dingcorrect"
                
            case .nomatch:
                soundFilename = "dingwrong"
                
            case .shuffle:
                soundFilename = "shuffle"
       
        }
        
        // Get resource path
        let bundlePAth = Bundle.main.path(forResource: soundFilename, ofType: ".wav")
        
        // Check that its not nil
        guard bundlePAth == nil else {
            // Couldnt find the resourse, exit
            return
        }
        
        let url = URL(fileURLWithPath: bundlePAth!)
        
        do {
            audioPlayer = AVPlayer(url: url)
            
            // play sound
            audioPlayer?.play()
        }
//        catch {
//            print("Couldnt create and audio player")
//            return
//        }
        
       
        
    }
    
}
