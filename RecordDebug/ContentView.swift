//
//  ContentView.swift
//  RecordDebug
//
//  Created by Thomas Walther on 2024-08-14.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State var isPlaying = false
    @State var isRecording = false
    
    var body: some View {
        VStack(spacing: 50) {
            if isRecording {
                Button("stop recording", systemImage: "square.fill", action: record)
            } else {
                Button("record", systemImage: "circle.fill", action: record)
            }
            if isPlaying {
                Button("pause", systemImage: "pause.fill", action: pause)
            } else {
                Button("play", systemImage: "play.fill", action: play)
            }
        }
        .padding()
    }
    
    func record() {
        if isRecording {
            TapeDeck.shared.stopRecording()
            isRecording = false
        } else {
            TapeDeck.shared.startRecording()
            isRecording = true
        }
    }
    
    func play() {
        TapeDeck.shared.play()
        isPlaying = true
    }
    
    func pause () {
        TapeDeck.shared.pause()
        isPlaying = false
    }
}

#Preview {
    ContentView()
}
