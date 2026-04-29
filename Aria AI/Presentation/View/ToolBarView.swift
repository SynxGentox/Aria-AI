//
//  ToolBarView.swift
//  Aria AI
//
//  Created by Aryan Verma on 29/04/26.
//

import SwiftUI
import EventKit

struct ToolBarView: View {
    var buttonLabels1 = ["Notifications", "Settings", "Language", "Apple Intelligence"]
    let events: [EKEvent]
    
    
    var body: some View {
            HStack {
                Menu {
                    ForEach (buttonLabels1, id: \.self) { text in
                        Button {
                        } label: {
                            VStack {
                                Text(text)
                                    .primaryStyle(fontSize: FontT.primary)
                            }
                        }
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.semibold)
                        .frame(width: ButtonT.WidthT.small + 5, height: ButtonT.HeightT.medium)
                        .padding(.horizontal, 30)
                }
                
                Spacer()
                let id = "tasks"
                NavigationLink(value: id) {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.semibold)
                        .frame(width: ButtonT.WidthT.small + 4, height: ButtonT.HeightT.medium)
                        .padding(.horizontal, 30)
                }
                .navigationDestination(for: String.self) {_ in
                    HistoryView(events: events)
                }
            }
    }
}

#Preview {
    let event: [EKEvent] = [EKEvent()]
    ToolBarView(events: event)
}
