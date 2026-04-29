//
//  Card.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 30/03/26.
//

import SwiftUI

struct Card: View {
    let radius: CGFloat
    let width: CGFloat
    let height: CGFloat
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(color)
            .frame(
                maxWidth: width,
                maxHeight: height
            )
    }
}

#Preview {
    Card(radius: 33, width: 200, height: 100, color: Color(UIColor.systemGray6))
}
