//
//  iconStyle.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 30/03/26.
//

import SwiftUI

extension Image {
    func iconStyle(buttonHeight: CGFloat, buttonWidth: CGFloat, iconColor: Color, alignLeft: Bool) -> some View {
        self
            .resizable()
            .scaledToFit()
            .fontWeight(.regular)
            .foregroundStyle(iconColor)
            .shadow(color: GetColor.ariaBackground.opacity(0.3), radius: 5, x: 5, y: 5)
            .padding(ButtonT.IconPaddingT.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignLeft ? .leading : .center)
            .frame(maxWidth: buttonWidth, maxHeight: buttonHeight)
    }
}

