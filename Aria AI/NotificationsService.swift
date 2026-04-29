//
//  NotificationsService.swift
//  Aria AI
//
//  Created by Aryan Verma on 28/04/26.
//

import Foundation
import UserNotifications
import EventKit

class NotificationsService: NotificationsProtocol {
    static let shared = NotificationsService()
    
    func taskReminder(event: EKEvent) {
        
        let content = UNMutableNotificationContent()
        content.title = event.title ?? "No task"
        content.sound = .default
        content.body = "\(event.startDate.formatted(date: .abbreviated, time: .shortened))"
        
        let component = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                        from: event.startDate.addingTimeInterval(-900))
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: false)
        let request = UNNotificationRequest(identifier: event.title ?? UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelReminder(event: EKEvent) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.title ?? ""])
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
