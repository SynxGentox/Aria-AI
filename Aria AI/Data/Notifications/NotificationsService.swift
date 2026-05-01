//
//  NotificationsService.swift
//  Aria AI
//
//  Created by Aryan Verma on 28/04/26.
//

import Foundation
import UserNotifications
import EventKit

/// design, schedule and request permission for the notification.
class NotificationsService: NotificationsProtocol {
    
    /// Schedules and Design the notification 15 minutes earlier to the task scheduled time.
    /// - Parameter event: takes the latest event from the today's list.
    func taskReminder(event: EKEvent) {
        
        // Design the notification content.
        let content = UNMutableNotificationContent()
        content.title = event.title ?? "No task"
        content.sound = .default
        content.body = "\(event.startDate.formatted(date: .abbreviated, time: .shortened))"
        
        // Assigns event date to the date component with 15 minutes positive delay.
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                        from: event.startDate.addingTimeInterval(-900))
        
        // Triggers the notification for the component.
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        // Requests the notification for the content using identifier.
        let request = UNNotificationRequest(identifier: event.eventIdentifier ?? UUID().uuidString, content: content, trigger: trigger)
        
        // Adds the notification request to the iOS notification center, this triggers the permission request.
        UNUserNotificationCenter.current().add(request)
    }
    
    
    /// allows the user to cancel the notification.
    /// - Parameter event: takes the latest event from the today's list.
    func cancelReminder(event: EKEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.eventIdentifier ?? ""])
    }
    
    /// Function to request Authorization from the iOS in UNUserNotificationCenter - UN is referred to framework (classic Apple), UserNotificationCenter refers to the Notification center but the compiler needs to know which notification center and thats why we use .current which means the current available Notification Center.
    /// - Parameter completion: it specifies whether the permission was granted or not.
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
