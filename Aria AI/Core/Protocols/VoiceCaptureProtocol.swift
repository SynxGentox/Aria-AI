//
//  VoiceCaptureProtocol.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

protocol VoiceCaptureProtocol {
    func requestAuthorization() async -> Bool
    func startListening() throws -> AsyncStream<String>
    func stopListening()
}
