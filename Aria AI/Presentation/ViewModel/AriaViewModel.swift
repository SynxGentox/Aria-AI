//
//  AriaViewModel.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Foundation
import Observation
import EventKit

/// Passes and receives the data to UseCase class and pushes the voice input to the VoiceService through protocol.
@Observable
class AriaViewModel {
    var transcribedText: String = ""
    var isListening: Bool = false
    var eventSaved: Bool = false
    var errorMsg: String?
    var todaysEvents: [EKEvent] = []
    var isProcessing: Bool = false
    private var pendingCommand: String? = nil
    
    private let useCase: AriaEventUseCase
    private let voice: VoiceCaptureProtocol
    private var listeningTask: Task<Void, Never>?
    
    init(voice: VoiceCaptureProtocol) {
        let notifications = NotificationsService()
            notifications.requestPermission { _ in }
        self.useCase = AriaEventUseCase(
            parser: AIParserService(),
            calendar: CalendarService(),
            notification: notifications
        )
        self.voice = voice
    }
    
    /// process the input when voice input starts.
    func startListening() {
        guard !isListening else { return }
        isListening = true
        transcribedText = ""
        errorMsg  = nil
        
        // fires the mic request when voice inputs.
        listeningTask = Task {
            let authorized = await voice.requestAuthorization()
            guard authorized else {
                errorMsg = "Mircrophone access denied."
                isListening = false
                return
            }
            
            // if the permission is granted starts the listening process and takes the input.
            do {
                let stream = try voice.startListening()
                for await text in stream {
                    transcribedText = text
                }
            } catch {
                errorMsg = error.localizedDescription
            }
            
            // resets the bool for next voice input.
            isListening = false
            processPrompt()
        }
    }
    
    /// stops the voice engine, resets the bool, resets the input, resets teh processPrempt func through guard condition in processPrompt func.
    func stopListening() {
        voice.stopListening()
        isListening = false
        listeningTask?.cancel()
        processPrompt()
    }
    
    /// Process the prompt
    private func processPrompt() {
        
        // checks whether input is empty or not and is any prompt in process or not.
        guard !transcribedText.isEmpty, !isProcessing else { return }
        // checks whether input is empty or not.
        guard !transcribedText.isEmpty else { return }
        
        // makes a single prompt to process, pendingCommand is for the condition in case user doesnt mentions the time of task.
        let promptToProcess = pendingCommand != nil ? "\(transcribedText) \(pendingCommand ?? "")" : transcribedText
        isProcessing = true
        Task {
            do {
                try await useCase.execute(prompt: promptToProcess)
                eventSaved = true
                
                // Hold the success state for 2 seconds, then reset.
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                // resets the states for next input.
                eventSaved = false
                transcribedText = ""
                isProcessing = false
            } catch let error as NSError {
                if error.domain == "AriaViewModel" && error.code == 2 {
                    pendingCommand = promptToProcess
                    errorMsg = "What time should I schedule this task?"
                    
                    // Auto-start listening again after a brief pause.
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    startListening()
                } else {
                    errorMsg = error.localizedDescription
                    pendingCommand = nil
                }
                isProcessing = false
            }
        }
    }
    
    // a function to access the processPrompt to fire it manually from UI.
    func submitText() {
        processPrompt()
    }
    
    // fetches the current day tasks.
    func fetchTodaysEvents() {
        todaysEvents = useCase.calendar.fetchToday()
    }
}
