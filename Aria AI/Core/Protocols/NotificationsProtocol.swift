//
//  NotificationsProtocol.swift
//  Aria AI
//
//  Created by Aryan Verma on 28/04/26.
//

import EventKit

protocol NotificationsProtocol {
    func taskReminder(event: EKEvent)
    func cancelReminder(event: EKEvent)
    func requestPermission(completion: @escaping (Bool) -> Void)
}
