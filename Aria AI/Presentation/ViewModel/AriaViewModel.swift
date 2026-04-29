//
//  AriaViewModel.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Foundation
import Observation
import EventKit

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
        self.useCase = AriaEventUseCase(
            parser: AIParserService(),
            calendar: CalendarService(),
            notification: NotificationsService.shared
        )
        NotificationsService.shared.requestPermission { _ in }
        self.voice = voice
    }
    
    func startListening() {
        guard !isListening else { return }
        isListening = true
        transcribedText = ""
        errorMsg  = nil
        
        listeningTask = Task {
            let authorized = await voice.requestAuthorization()
            guard authorized else {
                errorMsg = "Mircrophone access denied."
                isListening = false
                return
            }
            
            do {
                let stream = try voice.startListening()
                for await text in stream {
                    transcribedText = text
                }
            } catch {
                errorMsg = error.localizedDescription
            }
            isListening = false
            processPrompt()
        }
    }
    
    func stopListening() {
        voice.stopListening()
        isListening = false
        listeningTask?.cancel()
        processPrompt()
    }
    
    private func processPrompt() {
        guard !transcribedText.isEmpty, !isProcessing else { return }
        guard !transcribedText.isEmpty else { return }
        
        let promptToProcess = pendingCommand != nil ? "\(transcribedText) \(pendingCommand ?? "")" : transcribedText
        isProcessing = true
        Task {
            do {
                try await useCase.execute(prompt: promptToProcess)
                eventSaved = true
                
                // Hold the success state for 2 seconds, then reset
                try? await Task.sleep(nanoseconds: 1_600_000_000)
                eventSaved = false
                transcribedText = ""
                isProcessing = false
            } catch let error as NSError {
                if error.domain == "AriaViewModel" && error.code == 2 {
                    pendingCommand = promptToProcess
                    errorMsg = "What time should I schedule this task?"
                    
                    // Auto-start listening again after a brief pause
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    startListening()
                } else {
                    errorMsg = error.localizedDescription
                    pendingCommand = nil
                }
                isProcessing = false
            }
        }
    }
    
    func submitText() {
        processPrompt()
    }
    
    func fetchTodaysEvents() {
        todaysEvents = useCase.calendar.fetchToday()
    }
}
