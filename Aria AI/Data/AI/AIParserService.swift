//
//  AIParserService.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import FoundationModels
import Foundation

struct AIParserService: AIParserProtocol {
    private let session = LanguageModelSession()
    private let model = SystemLanguageModel.default
    
    func parse(prompt: String) async throws -> AriaEvent {
        
        // Check availability first
        switch model.availability {
            case .available:
                break
            case .unavailable(.deviceNotEligible):
                throw NSError(domain: "AIParserService", code: 3,
                              userInfo: [NSLocalizedDescriptionKey:
                                            "Aria requires Apple Intelligence — iPhone 15 Pro or later."])
            case .unavailable(.appleIntelligenceNotEnabled):
                throw NSError(domain: "AIParserService", code: 4,
                              userInfo: [NSLocalizedDescriptionKey:
                                            "Please enable Apple Intelligence in Settings."])
            case .unavailable(.modelNotReady):
                throw NSError(domain: "AIParserService", code: 5,
                              userInfo: [NSLocalizedDescriptionKey:
                                            "Model not ready. Please wait."])
            case .unavailable(_):
                throw NSError(domain: "AIParserService", code: 6,
                              userInfo: [NSLocalizedDescriptionKey:
                                            "Apple Intelligence unavailable."])
        }
        
        let today = ISO8601DateFormatter().string(from: Date())
        
        let instruction = """
            Today's Date is \(today).
            Extract calendar event details from this voice command.
            Time inference rules:
                - If user says "10 o'clock" or "10:00" with no AM/PM:
                  → If current time is before 10:00, assume 10:00 (24-Hours)
                  → If current time is after 10:00, assume 22:00 (24-Hours)
                - If user says "22:00" or any unambiguous 24hr time, use it directly
                - Resolve relative terms like 'next Monday' to absolute dates.
                - Convert terms like "1 hours from now" into absolute dates.
                - "tomorrow" = today's date + 1 day
                - "day after tomorrow" = today's date + 2 days
                - Beyond that, use the exact date mentioned
                - Always return date in yyyy-MM-dd format
                - Always return time in HH:mm 24-hour format
                - If only date is given then assign task to current time on the provided date
                - If only time is given then assign task to current date on the provided time
                
            If a field has no information, return nil for it.
            
            Voice command: \(prompt)
            """
        
        return try await session.respond(
            to: instruction,
            generating: AriaEvent.self
        ).content
    }
}
