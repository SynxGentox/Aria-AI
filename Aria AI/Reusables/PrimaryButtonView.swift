//
//  AddExpenseView.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 30/03/26.
//

import SwiftUI

struct PrimaryButton: View {
    let buttonDisplay: String
    let infinite: Bool
    let alignLeft: Bool
    var isSelected: Bool = false
    let action: () -> Void
    
    
    var body: some View {
        VStack {
            Button(action: action) {
                PolymorphicStyle(
                    isImage: buttonDisplay,
                    infinite: infinite,
                    alignLeft: alignLeft
                )
            }
            .buttonStyle(PrimaryButtonStyle(isSelected: isSelected))
        }
    }
}

struct PrimaryNavigationButton<Destination: View>: View {
    let buttonDisplay: String
    let infinite: Bool
    let alignLeft: Bool
    var isSelected: Bool = false
    let destination: Destination
    let id: String
    
    var body: some View {
        VStack {
            NavigationLink(value: id) {
                PolymorphicStyle(
                    isImage: buttonDisplay,
                    infinite: infinite,
                    alignLeft: alignLeft
                )
            }
            .navigationDestination(for: String.self) { _ in
                destination
            }
            .buttonStyle(PrimaryButtonStyle(isSelected: isSelected))
            
        }
    }
}

#Preview {
    PrimaryButton(buttonDisplay: "apple.homekit", infinite: false, alignLeft: false, action: {})
}

