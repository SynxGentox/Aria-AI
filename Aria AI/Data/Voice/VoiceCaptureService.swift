//
//  VoiceCaptureService.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Speech
import AVFoundation
import Foundation

/// Authorizes, listens and stops litening using system AudioEngine.
class VoiceCaptureService: VoiceCaptureProtocol {
    
    // speech recognizer currently only supports the english US.
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    // MARK: - Authorization.
    /// Requests the permission to use microphone for speech recognition.
    /// - Returns: whether the authorization was approved (true) or not (false).
    func requestAuthorization() async -> Bool {
        // Old Apple APIs use callbacks, withCheckedContinuation forces it into modern async/await.
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    /// Starts listening once the permission is approved and transcripts the speech into a AsyncStream String.
    /// - Returns: AsyncStream of String type which is the output from speech recognition.
    func startListening() throws -> AsyncStream<String> {
        // Always reset the state before starting a new session to prevent hardware crashes.
        stopListening()
        
        // sharedInstance is the singleton of the AVAudioSession class which is inbuilt.
        let audioSession = AVAudioSession.sharedInstance()
        // setCategory decides what type of session we want. here, .record is for recording type session, .measurement refers to raw input which is named domain specifically, .duckOthers mean the audio of other sources will be reduced when session is active.
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
        // when declaring AsyncStream swift hands us an object named continuation which is similar to control value. Using (.yield) this we can push the data through the pipeline, (.finish) closes the pipeline, (.onTermination) handles the termination condition.
        return AsyncStream { continuation in
            // Start recognizer.
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                
                if let result = result {
                    // this updated the string directly on the ViewModel to update the UI instantly.
                    continuation.yield(result.bestTranscription.formattedString)
                    // if the user finishes talking (.isFinal) or mic breaks (error) this will stop the stream first through stopListening function call then it shutsdown the hardware.
                    // Stream should be closed before stutting down the hardware i.e. mic. otherwise the stream will crash bcz of unexpected hardware mic break.
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
            
            // start the mic AFTER setting up the task.
            // installTap literlly installs a tap like a switch on the main source i.e. mic.
            // bus refers to the audio channel 0 is for default/primary audio channel.
            // bufferSize means raw audio data.
            input.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                // recognitionRequest 
                self.recognitionRequest?.append(buffer)
            }
            
            self.audioEngine.prepare()
            try? self.audioEngine.start()
            
            // this part makes sure that the AVAudioEngine stops listening on termination of AsyncStream.
            continuation.onTermination = { @Sendable _ in
                self.stopListening()
            }
        }
        
        
    }
    // Hardware Stop function.
    // stops the audio engine.
    func stopListening() {
        
        // stops the engine and removes tap from default audio channel.
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // ends the reconition request and terminates the task.
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        // resets the request and task.
        recognitionRequest = nil
        recognitionTask = nil
    }
}
