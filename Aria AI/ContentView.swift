//
//  ContentView.swift
//  Aria AI
//
//  Created by Aryan Verma on 23/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onAppear {
                    Task {
                        do {
                            let parser = AIParserService()
                            let event = try await parser.parse(
                                prompt: "Remind me to call mom tomorrow at 8 PM for 1 hour at home"
                            )
                            let repo = CalendarService()
                            let request = await repo.requestAccess()
                            print("AccessGranted", request)
                            if request {
                                try await repo.save(event: event)
                            }
                            print("✅ Title:", event.title)
                            print("✅ Date:", event.date ?? "nil")
                            print("✅ Start:", event.startTime ?? "nil")
                            print("✅ End:", event.endTime ?? "nil")
                            print("✅ Location:", event.location ?? "nil")
                            
                            let useCase = AriaEventUseCase(
                                parser: AIParserService(),
                                calendar: CalendarService()
                            )
                            try await useCase.execute(prompt: "remind me to call myself at 11:00 pm")
                            print("event created")
                        } catch {
                            print("❌ Error:", error)
                        }
                    }
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
