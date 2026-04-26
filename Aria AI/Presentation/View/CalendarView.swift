//
//  CalendarView.swift
//  Aria AI
//
//  Created by Aryan Verma on 26/04/26.
//

import SwiftUI
import EventKit

struct CalendarView: View {
    @State var viewModel: AriaViewModel
    
    var body: some View {
        NavigationStack {
            List (viewModel.todaysEvents, id:\.eventIdentifier) { item in
                Text(item.title)
                    .fontWeight(.bold)
                Text(item.startDate.formatted(date: .abbreviated, time: .shortened))
                    .fontWeight(.semibold)
            }
        }
        .navigationTitle("Today's Events")
        .onAppear{ viewModel.fetchTodaysEvents() }
    }
}

#Preview {
    CalendarView(viewModel: AriaViewModel())
}
