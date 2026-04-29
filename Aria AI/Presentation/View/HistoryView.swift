//
//  HistoryView.swift
//  Aria AI
//
//  Created by Aryan Verma on 29/04/26.
//

import SwiftUI
import EventKit

struct HistoryView: View {
    let events: [EKEvent]
    
    var body: some View {
        ZStack {
            GetColor.ariaBackground
                .ignoresSafeArea()
            ScrollView {
                ForEach (events, id:\.eventIdentifier) { event in
                    ZStack {
                        Card(
                            radius: CardT.RadiusOrPaddingT.smoothRadius,
                            width: CardT.WidthT.infinity,
                            height: CardT.HeightT.medium/1.3,
                            color: GetColor.ariaSurface.opacity(0.13)
                        )
                        HStack(alignment: .firstTextBaseline) {
                            Text("Task - " + event.title)
                                .primaryStyle(fontSize: FontT.primary)
                            Spacer()
                            VStack(alignment: .listRowSeparatorLeading) {
                                Text(event.startDate.formatted(date: .numeric, time: .shortened))
                                    .primaryStyle(fontSize: FontT.secondary + 3)
                                Text(event.endDate?.formatted(date: .numeric, time: .shortened) ?? "N/A")
                                    .primaryStyle(fontSize: FontT.secondary + 3)
                            }
                            .frame(maxHeight: CardT.HeightT.medium/1.3)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Assigned Tasks")
    }
}

#Preview {
    let event: [EKEvent] = [EKEvent()]
    HistoryView(events: event)
}
