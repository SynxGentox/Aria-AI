//
//  CalendarService.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import EventKit

class CalendarService: CalendarRepositoryProtocol {
    
    /// EKEventStore is an IPC (Inter-Process Communication) connection to the iOS Calendar daemon running in the background of the iPhone.
    /// EKEventStore is computationally heavy by declaring it as a single private let at class level we are opening the database connection once and keep it alive in memory.
    /// we didnt put it inside teh save function bcz if we did the app would lag because it would have to rebuild it again and again each time save function accessed.
    private let store = EKEventStore()
    
    func requestAccess() async -> Bool {
        do {
            // iOS apps lives in a sandbox they cant access decive data without permission.
            // await pauses the app's task and yeilds the thread back for brief moment unitl the user either deny or allows the permission.
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }
    
    /// saves the event returned form the AI parser service in the abstract JSON format by LLM to the calendar.
    /// - Parameter event: event received from AI parser service.
    func save(event: AriaEvent) async throws -> EKEvent {
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.location = event.location
        ekEvent.calendar = store.defaultCalendarForNewEvents    // uses the default calendar to store events.
        
        // takes the LLM string and uses DateFormatter to convert it into a unix timestamp (seconds since 1970).
        // we kept both formats to catch any type of date format, Either 24 hours or 12 hours format.
        let formatter = DateFormatter()
        let formats = ["yyyy-MM-dd HH:mm", "yyyy-MM-dd hh:mm a"]
        
        
        let dateString = event.date ?? nil
        guard let startTimeString = event.startTime else {
            // throw error if LLM model didnt receive time of event.
            throw NSError(domain: "CalendarRepository", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No start time provided"])
        }
        
        let startString = "\(dateString ?? "") \(startTimeString)"
        var startDate: Date?
        var endDate: Date?

        let endString = event.endTime.map { "\(dateString ?? "") \($0)" }

        for format in formats {
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            startDate = formatter.date(from: startString)
            if let endStr = endString {
                endDate = formatter.date(from: endStr)
            }
            if startDate != nil { break }
        }

        guard let startDate = startDate else {
            throw NSError(domain: "CalendarRepository", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }

        let finalEndDate = endDate ?? startDate.addingTimeInterval(3600)

        ekEvent.startDate = startDate
        ekEvent.endDate = finalEndDate
        // (span: .thisEvent) tells iOS that if this happened to be a recurring event (like "every Tuesday"), it should only modify this specific instance, not the entire series.
        try store.save(ekEvent, span: .thisEvent)
        return ekEvent
    }
    
    func fetchToday() -> [EKEvent] {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.date(byAdding: .day, value: 1, to: start) ?? Date.now
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        return store.events(matching: predicate).sorted {$0.startDate < $1.startDate}
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
