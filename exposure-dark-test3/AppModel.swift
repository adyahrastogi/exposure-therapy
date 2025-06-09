//
//  AppModel.swift
//  exposure-dark-test3
//
//  Created by Adyah Rastogi on 5/5/25.
//

import SwiftUI
import AVFoundation

enum DarknessLevel: CGFloat, CaseIterable {
    case off = 0.0
    case light = 0.8
    case medium = 0.9
    case dark = 0.99
}

@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var currentDarkness: DarknessLevel = .dark
    var currentAlpha: CGFloat {
        immersiveSpaceState == .open ? currentDarkness.rawValue : 0.0
    }

    var windSoundPlayer: AVAudioPlayer?
    var creakingSoundPlayer: AVAudioPlayer?

    init() {
        setupAudioPlayers()
    }

    func setupAudioPlayers() {
        if let windSoundURL = Bundle.main.url(forResource: "wind", withExtension: "mp3") {
            do {
                windSoundPlayer = try AVAudioPlayer(contentsOf: windSoundURL)
                windSoundPlayer?.numberOfLoops = -1
                windSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not load wind sound file: \(error.localizedDescription)")
            }
        } else {
            print("Wind sound file (wind.mp3) not found in bundle.")
        }

        if let creakingSoundURL = Bundle.main.url(forResource: "creaking", withExtension: "wav") {
            do {
                creakingSoundPlayer = try AVAudioPlayer(contentsOf: creakingSoundURL)
                creakingSoundPlayer?.numberOfLoops = 0
                creakingSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not load creaking sound file (creaking.wav): \(error.localizedDescription)")
            }
        } else {
            print("Creaking sound file (creaking.wav) not found in bundle.")
        }
    }

    func playWindSound() {
        if windSoundPlayer?.isPlaying == false {
            windSoundPlayer?.play()
        }
    }

    func stopWindSound() {
        if windSoundPlayer?.isPlaying == true {
            windSoundPlayer?.stop()
            // Optional: Reset playback to the beginning if you want it to start fresh next time
            // windSoundPlayer?.currentTime = 0
        }
    }

    func playCreakingSound() {
        if creakingSoundPlayer?.isPlaying == true {
            creakingSoundPlayer?.currentTime = 0
        }
        creakingSoundPlayer?.play()
    }

    // --- NEW METHOD TO STOP ALL IMMERSIVE SOUNDS ---
    func stopAllImmersiveSounds() {
        print("Stopping all immersive sounds.") // For debugging
        stopWindSound() // Stops the wind sound

        // If creaking sound or other sounds could be looping or long-playing, stop them too
        if creakingSoundPlayer?.isPlaying == true {
            creakingSoundPlayer?.stop()
            // creakingSoundPlayer?.currentTime = 0 // Optional reset
        }
        // Add stops for any other sounds here
    }
}
