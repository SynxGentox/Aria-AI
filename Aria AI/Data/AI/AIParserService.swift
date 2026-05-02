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
    
    /// parser function to process the prompt, instruction and date provided to get an event
    /// - Parameter prompt: event provided by the user to assign an event.
    /// - Returns: returns a JSON format string of the event.
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let currentTimeString = timeFormatter.string(from: Date())
        
        
        let instruction = """
            
            Current System Context:
                - Date: \(currentDateString)
                - Time: \(currentTimeString)
                
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
                - If no time is mentioned by the user at all, return nil for startTime. Do NOT infer, assume, or assign any time.
                - If only date is given with no time, return nil for startTime
                - If only time is given with no date, use today's date and return that time
                - Only populate startTime if the user explicitly mentioned a time
                
            If a field has no information, return nil for it.
            
            Voice command: \(prompt)
            """
        
        
// MARK: - The full runtime pipeline.
        // 1. The Packaging: -   Language Model Session takes the prompt and the schema.
        // 2. The Request: -     Sends both prompt and schema to the Apple Intelligence.
        // 3. Structured Gen.: - Instead of generating a free floating text Apple uses a technique called Grammer-Constrained Generation (or Tool Calling). It can only return the text that matches the blueprint (schema) and it is forced to output a perfectly formatted JSON string.
        // 4. The Decoding: -    The framework receives teh JSON string form LLM model, silently decodes it back to Data Model struct and hands it to the .content wrapper.
        
        return try await session.respond(
            to: instruction,
            generating: AriaEvent.self
        ).content
    }
}
