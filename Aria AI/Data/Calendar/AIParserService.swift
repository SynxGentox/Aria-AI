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
    
    func parser(prompt: String) async throws -> AriaEvent {
        let today = ISO8601DateFormatter().string(from: Date())
        
        let instruction = """
            Today's Date is \(today).
            Extract calendar event details from this voice command.
            Resolve relative terms like 'tomorrow' or 'next Monday' to absolute dates.
            If a field has no information, return nil for it.
            
            Voice command: \(prompt)
            """
        
        return try await session.respond(
            to: instruction,
            generating: AriaEvent.self
        ).content
    }
}
