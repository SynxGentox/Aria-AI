//
//  AIParserProtocol.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import FoundationModels

protocol AIParserProtocol {
    func parse(prompt: String) async throws-> AriaEvent
}
