//
//  PrimaryButtonStyle.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 30/03/26.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed || isSelected
                ? GetColor.ariaBackground.opacity(0.6)
                : GetColor.ariaSurface // static state color
            )
            .clipShape(.circle)
        // 2. The Spatial Brightness Bump
        // 3. The Neon Glow (Shadow)
            .shadow(
                color: configuration.isPressed ? .ariaSurface.opacity(0.7) : .clear,
                radius: configuration.isPressed ? 8 : 0
            )
            .scaleEffect(configuration.isPressed || isSelected ? 1.15 : 1.0)
        // Smoothly animate the transition between states
            .animation(.spring(duration: 0.3, bounce: 0.5, blendDuration: 0.5), value: configuration.isPressed || isSelected)
    }
}

struct ActionButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed || isSelected
                ? GetColor.ariaWarm.opacity(0.3)
                : GetColor.clear// static state color
            )
            .clipShape(.circle)
        // 2. The Spatial Brightness Bump
        // 3. The Neon Glow (Shadow)
            .shadow(
                color: configuration.isPressed ? .ariaSurface.opacity(0.7) : .clear,
                radius: configuration.isPressed ? 8 : 0
            )
            .scaleEffect(configuration.isPressed || isSelected ? 1.15 : 1.0)
        // Smoothly animate the transition between states
            .animation(.spring(duration: 0.3, bounce: 0.5, blendDuration: 0.5), value: configuration.isPressed || isSelected)
    }
}
