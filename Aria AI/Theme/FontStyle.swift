//
//  GeneralFontExt.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 30/03/26.
//

import SwiftUI

struct PrimaryStyle: ViewModifier {
    let fontSize: CGFloat
    func body(content: Content) -> some View {
        content
            .foregroundStyle(GetColor.ariaAccent)
            .font(
                .system(size: fontSize, weight: .regular, design: .serif)
            )
    }
}

extension View {
    func primaryStyle(fontSize: CGFloat) -> some View {
        modifier(PrimaryStyle(fontSize: fontSize))
    }
}

struct SecondaryStyle: ViewModifier {
    let fontSize: CGFloat
    func body(content: Content) -> some View {
        content
            .foregroundStyle(GetColor.sysGray)
            .font(
                .system(size: fontSize, weight: .medium, design: .serif)
            )
    }
}

extension View {
    func secondaryStyle(fontSize: CGFloat) -> some View {
        modifier(SecondaryStyle(fontSize: fontSize))
    }
}


struct AmountStyle: ViewModifier {
    let fontSize: CGFloat
    func body(content: Content) -> some View {
        content
            .foregroundStyle(GetColor.ariaAccent)
            .font(
                .system(size: fontSize, weight: .semibold, design: .serif)
            )
            
    }
}

extension View {
    func amountStyle(fontSize: CGFloat) -> some View {
        modifier(AmountStyle(fontSize: fontSize))
    }
}
