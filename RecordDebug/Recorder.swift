//
//  Recorder.swift
//  TapeIt
//
//  Created by Thomas Walther on 20.06.20.
//  Copyright © 2020 Tape It Music GmbH. All rights reserved.
//

import AVFoundation
import UIKit


// MARK: Recorder
class Recorder {
    // Audio Recording
    private let sampleRate: Double = 44100
    private let engine = AVAudioEngine()
    private let recorderNode = AVAudioMixerNode()
    private var outputFile: AVAudioFile?
    
    init(url: URL) throws {
        self.outputFile = try AVAudioFile(
            forWriting: url,
            settings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
        )
        
        try initAudioGraph()
        try setupTap()
    }
}


// MARK: Start and stop recording
extension Recorder {
    func record() throws {
        try engine.start()
    }
    
    func stop() {
        engine.stop()
        engine.reset()
        
        outputFile = nil
    }
}


// MARK: // Private
// MARK: Initialization
private extension Recorder {
    func initAudioGraph() throws {
        // This format must not be interleaved, otherwise AVAudioEngine crashes
        let recordingOutputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false)!
        
        // This sets the input volume of those nodes in their destination node (mainMixerNode) to 0.
        // The raw outputVolume of these nodes remains 1, so when you tap them you still get the samples.
        // If you set outputVolume = 0 instead, the taps would only receives zeros.
        recorderNode.volume = 0
        
        engine.attach(recorderNode)
        engine.connect(engine.mainMixerNode,    to: engine.outputNode,      format: engine.outputNode.inputFormat(forBus: 0))
        engine.connect(recorderNode,            to: engine.mainMixerNode,   format: recordingOutputFormat)
        engine.connect(engine.inputNode,        to: recorderNode,           format: engine.inputNode.inputFormat(forBus: 0))
    }
    
    func setupTap() throws {
        let bufferSize: AVAudioFrameCount = 4096
        recorderNode.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { [weak self] buffer, time in
            guard let self = self else { return }
            
            // Write recording to disk
            do {
                try outputFile?.write(from: buffer)
            } catch {
                stop()
            }
        }
    }
}
