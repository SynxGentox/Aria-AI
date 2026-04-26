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
    
    private let useCase: AriaEventUseCase
    private let voice: VoiceCaptureService
    private var listeningTask: Task<Void, Never>?
    
    init() {
        self.useCase = AriaEventUseCase(
            parser: AIParserService(),
            calendar: CalendarService()
        )
        self.voice = VoiceCaptureService()
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
        }
    }
    
    func stopListening() {
        voice.stopListening()
        isListening = false
        listeningTask?.cancel()
        Task {
            do {
                try await useCase.execute(prompt: transcribedText)
                eventSaved = true
            } catch {
                errorMsg = error.localizedDescription
            }
        }
    }
    
    func fetchTodaysEvents() {
        todaysEvents = useCase.calendar.fetchToday()
    }
}
