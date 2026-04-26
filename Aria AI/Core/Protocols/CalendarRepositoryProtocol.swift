import EventKit

protocol CalendarRepositoryProtocol {
    func requestAccess() async -> Bool
    func save(event: AriaEvent) async throws
}

class CalendarRepository: CalendarRepositoryProtocol {
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
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString = event.date ?? currentDateString()
//        let _ = "\(dateString) \(event.endTime ?? "10:00")"         // endString
        
        // After you have startDate resolved, derive endDate from it
        // If no startTime, throw a meaningful error instead of guessing
        guard let startTimeString = event.startTime else {
            throw NSError(domain: "CalendarRepository", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "No start time provided"])
        }
        
        let startString = "\(dateString) \(startTimeString)"

        guard let startDate = formatter.date(from: startString) else {
            throw NSError(domain: "CalendarRepository", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid date format"])
        }

        // endDate = parsed endTime OR startDate + 1 hour
        let endDate: Date
        if let endTimeString = event.endTime,
           let parsedEnd = formatter.date(from: "\(dateString) \(endTimeString)") {
            endDate = parsedEnd
        } else {
            endDate = startDate.addingTimeInterval(3600) // exactly 1 hour after actual start
        }

        ekEvent.startDate = startDate
        ekEvent.endDate = endDate
        
        try store.save(ekEvent, span: .thisEvent)
        print("✅ Event saved:", ekEvent.title ?? "")
    }
    
    private func currentDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
