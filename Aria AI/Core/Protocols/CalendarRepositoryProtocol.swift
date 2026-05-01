//
//  CalendarRepositoryProtocol.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import EventKit

protocol CalendarRepositoryProtocol {
    func requestAccess() async -> Bool
    func save(event: AriaEvent) async throws -> EKEvent
    func fetchToday() -> [EKEvent]
}


