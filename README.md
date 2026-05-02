# Aria AI

A fully on-device voice-to-calendar assistant built with Apple Intelligence. 
Speak a task naturally — Aria parses it, saves it to your calendar, and reminds you 15 minutes before.

---

## Performance

- Memory: ~16MB idle, peaks ~28MB - 30MB under load
- CPU: 0% idle, Energy Impact: Low
- Benchmarked on iPad 10th gen, A14 Bionic, 4GB RAM

---

## Features

- Voice input via SFSpeechRecognizer with real-time transcription
- On-device natural language parsing using FoundationModels (Apple Intelligence)
- Automatic EventKit calendar integration
- Local notifications scheduled 15 minutes before each event
- History view of today's assigned tasks
- Manual text input fallback

---

## Architecture

Clean Architecture with Protocol-oriented dependency injection
```
Voice Input → VoiceCaptureService (AsyncStream)
                      ↓
              AriaViewModel (@Observable)
                      ↓
            AriaEventUseCase (Business Logic)
            ↙              ↓              ↘
AIParserService    CalendarService    NotificationsService
(FoundationModels)   (EventKit)      (UserNotifications)
```

---

## Tech Stack

- SwiftUI + @Observable
- FoundationModels — fully on-device, zero API calls, private by design
- EventKit — calendar read/write
- SFSpeechRecognizer + AVAudioEngine — wrapped in AsyncStream
- UserNotifications — local push reminders
- Protocol DI — all services injected via protocols, fully testable

---

## Privacy

All processing happens on-device. No data leaves the device at any point.

---

## Screenshots

 - <img src="Aria AI/Assets/light_mode.png" width="250">
 - <img src="Aria AI/Assets/dark_mode.png" width="250">
 - <img src="Aria AI/Assets/memory_graph.png" width="250">
 - <img src="Aria AI/Assets/cpu_graph.png" width="250">
 - <img src="Aria AI/Assets/energy_graph.png" width="250">
