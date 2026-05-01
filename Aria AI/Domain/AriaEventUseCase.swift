//
//  AriaEventUseCase.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Foundation

/// Links the services together.
class AriaEventUseCase {
    private let parser: AIParserProtocol
    let calendar: CalendarRepositoryProtocol
    private let notification: NotificationsProtocol
    
    init(parser: AIParserProtocol, calendar: CalendarRepositoryProtocol, notification: NotificationsProtocol) {
        self.parser = parser
        self.calendar = calendar
        self.notification = notification
    }
    
    /// Exectues the calendar request, passes the prompt to AI, saves the event returned by AI, triggers notificaition for the event saved.
    /// - Parameter prompt: text input by user.
    func execute(prompt: String) async throws {
        let hasAccess = await calendar.requestAccess()
        guard hasAccess else {
            throw NSError(
                domain: "AriaEventUseCase",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Calendar access denied"]
            )
        }
        let event = try await parser.parse(prompt: prompt)
        let saved = try await calendar.save(event: event)
        
        // fetch the saved event.
        notification.taskReminder(event: saved)
    }
}
