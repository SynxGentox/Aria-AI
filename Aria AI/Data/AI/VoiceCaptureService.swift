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
    
    // 1. The Authorization Wrap
    // Old Apple APIs use callbacks. We use withCheckedContinuation to force it into modern async/await.
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
        
        let inputNode = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw NSError(domain: "VoiceCaptureService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request"])    // Custom Swift Error (Enum) can be used, Recommended for Produciton Apps but NSError works fine here.
        }
        
        // We want partial as the user speaks, not just the final sentence
        recognitionRequest.shouldReportPartialResults = true
        
        // 3. The Bridge: Wrapping the messy callback inside the AsyncStream
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
            
            // THIS goes outside — start the mic AFTER setting up the task
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()
            try? self.audioEngine.start()
            
            continuation.onTermination = { @Sendable _ in
                self.stopListening()
            }
        }
        
        
    }
    // 5. The Hardware Shutdown
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
    }
}
