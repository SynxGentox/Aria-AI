//
//  VoiceCaptureService.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Speech
import AVFoundation
import Foundation

class VoiceCaptureService: VoiceCaptureProtocol {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    // 1. Authorization
    // Old Apple APIs use callbacks, withCheckedContinuation forces it into modern async/await.
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startListening() throws -> AsyncStream<String> {
        // Always reset the state before starting a new session to prevent hardware crashes
        stopListening()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let input = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let recordingFormat = input.outputFormat(forBus: 0)
        
        
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceCaptureService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])
            // Custom Swift Error (Enum) can be used, Recommended for Produciton Apps but NSError works fine here.
        }
        
        // Real time output, Don't wait for final output for user engagment.
        recognitionRequest.shouldReportPartialResults = true
        
        // Wrapping the messy callback inside the AsyncStream
        return AsyncStream { continuation in
            // Start recognizer
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    continuation.yield(result.bestTranscription.formattedString)
                    if result.isFinal || error != nil {
                        self.stopListening()
                        continuation.finish()
                    }
                }
            }
            
            guard recordingFormat.sampleRate > 0 else {
                continuation.finish()
                return
            }
            
            // start the mic AFTER setting up the task
            let recordingFormat = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()
            try? self.audioEngine.start()
            
            continuation.onTermination = { @Sendable _ in
                self.stopListening()
            }
        }
        
        
    }
    // Hardware Stop function
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}
