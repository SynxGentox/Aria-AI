//
//  AriaEvent.swift
//  Aria AI
//
//  Created by Aryan Verma on 24/04/26.
//

import FoundationModels

/// The Data Structure for LLM model to return data in this format.
/// @Generable: - It conforms to a hidden protocol and generates a boilerplate code which is a strict machine readable blueprint (a schema) of this struct.
/// basically translates your code into a blueprint for LLM (Large Language Model).
@Generable
struct AriaEvent {
    
    // @Guide: - Without this the LLM model cant understant what these variables means by providing the description, it directly injects that string into the schema that generable has build for LLM model to let it know what does each one mean.
    
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

// MARK: - Macro-s
// Macro-s are the compiler plugins that runs right before the compiler code. By using a macro the compiler automatically generated boilerplate code that automatically for that data.


// Swift is a strictly typed langauge while LLM models returns a raw string reguardless of your data type.

// MARK: - Traditional method flaws.
// Traditionally we had to force LLM model to return a json object with variables names and their type then make sure the json format is valid, decode the data through JSONDecoder and hope the LLM model didnt actually inculded markdowns to break the parser.

