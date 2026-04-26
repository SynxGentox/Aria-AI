//
//  AriaEvent.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import FoundationModels

@Generable
struct AriaEvent {
    
    @Guide(description: "Title of the calendar event, inferred from the voice command")
    var title: String
    
    @Guide(description: "Date of the event in yyyy-MM-dd format (e.g. 2026-04-26). Resolve relative terms like 'tomorrow' or 'next Monday' to an absolute date. Nil if not mentioned.")
    var date: String?
    
    @Guide(description: "Start time of the event in HH:mm 24-hour format (e.g. 20:00). Nil if not mentioned.")
    var startTime: String?
    
    @Guide(description: "End time of the event in HH:mm 24-hour format. Nil if not mentioned.")
    var endTime: String?
    
    @Guide(description: "Location of the event. Nil if not mentioned.")
    var location: String?
}
