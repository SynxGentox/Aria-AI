//
//  CalendarService.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import EventKit

class CalendarService: CalendarRepositoryProtocol {
    private let store = EKEventStore()
    
    func requestAccess() async -> Bool {
        do {
            return try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
    }
    
    func save(event: AriaEvent) async throws {
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.location = event.location
        ekEvent.calendar = store.defaultCalendarForNewEvents
        
        // Convert AriaEvent strings → Date objects
        let formatter = DateFormatter()
        let formats = ["yyyy-MM-dd HH:mm", "yyyy-MM-dd hh:mm a"]
        
        
        let dateString = event.date ?? currentDateString()
        guard let startTimeString = event.startTime else {
            throw NSError(domain: "CalendarRepository", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No start time provided"])
        }
        
        let startString = "\(dateString) \(startTimeString)"
        var startDate: Date?
        var endDate: Date?

        let endString = event.endTime.map { "\(dateString) \($0)" }

        for format in formats {
            formatter.dateFormat = format
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
        try store.save(ekEvent, span: .thisEvent)
        print("✅ Event saved:", ekEvent.title ?? "")
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
