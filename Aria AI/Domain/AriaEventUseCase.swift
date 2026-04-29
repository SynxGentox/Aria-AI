//
//  AriaEventUseCase.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import Foundation

class AriaEventUseCase {
    private let parser: AIParserProtocol
    let calendar: CalendarRepositoryProtocol
    private let notification: NotificationsProtocol
    
    init(parser: AIParserProtocol, calendar: CalendarRepositoryProtocol, notification: NotificationsProtocol) {
        self.parser = parser
        self.calendar = calendar
        self.notification = notification
    }
    
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
        try await calendar.save(event: event)
        
        // fetch the just saved event
        if let savedEvent = calendar.fetchToday().last {
            notification.taskReminder(event: savedEvent)
        }
    }
    
}
