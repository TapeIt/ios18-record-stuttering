//
//  TapeDeck.swift
//  TapeIt
//
//  Created by Thomas Walther on 03.06.20.
//  Copyright © 2020 Tape It Music GmbH. All rights reserved.
//

import AVFoundation

class TapeDeck {
    // Singleton
    static let shared: TapeDeck = TapeDeck()
    static private let audioURL = FileManager.default.temporaryDirectory.appending(path: "audio.m4a")
    
    // Playback
    private var player: AVAudioPlayer?
    
    // Recording
    private var recorder: Recorder?
    
    // AudioSession
    private var isAudioSessionConfigured: Bool = false
}

// MARK: Playback
extension TapeDeck {
    func play() {
        self.player = try? AVAudioPlayer(contentsOf: Self.audioURL)
        player?.play()
    }
    
    func pause() {
        self.player?.pause()
        self.player = nil
    }
}

// MARK: Recording Functions
extension TapeDeck {
    // Permission convenience method
    // The response callback will always be called on the main thread
    func requestRecordPermission(_ response: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission(completionHandler: { granted in
            DispatchQueue.main.async { response(granted) }
        })
    }
    
    @discardableResult
    func startRecording() -> Bool {
        guard activateSession() else { return false }
        
        do {
            self.recorder = try Recorder(url: Self.audioURL)
            try recorder?.record()
            return true
        } catch {
            recorder = nil
            return false
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }
}


extension TapeDeck {
    @discardableResult
    func activateSession() -> Bool {
        // We return true for these guard statements as in both cases it's fine for
        // the caller to continue.
        guard !isAudioSessionConfigured else { return true }
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay])
            try session.setActive(true)
            print("session activated")
            return true
        } catch {
            print(error)
            return false
        }
        
    }
}
