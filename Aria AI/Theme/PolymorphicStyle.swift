//
//  PolymorphicStyle.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 01/04/26.
//

import SwiftUI

struct PolymorphicStyle: View {
    let isImage: String
    let infinite: Bool
    let alignLeft: Bool
    var body: some View {
        isImage(str: isImage)
    }
    @ViewBuilder
    func isImage(str: String) -> some View {
        if UIImage(systemName: str) != nil {
            Image(systemName: str)
            // Got to iconStyle.swift to edit the iconStyle
                .iconStyle(
                    buttonHeight: ButtonT.HeightT.large,
                    buttonWidth: infinite ? ButtonT.WidthT.infinite : ButtonT.WidthT.large,
                    iconColor: GetColor.ariaAccent, alignLeft: alignLeft
                )
        }
        else if UIImage(named: str) != nil {
            Image(str)
            // Got to iconStyle.swift to edit the iconStyle
                .iconStyle(
                    buttonHeight: ButtonT.HeightT.large,
                    buttonWidth: infinite ? ButtonT.WidthT.infinite : ButtonT.WidthT.large,
                    iconColor: GetColor.ariaAccent, alignLeft: alignLeft
                )
        }
        else {
            Text(str)
            // Go to FontStyle.swift to change buttonStyle
                .amountStyle(fontSize: FontT.primary)
                .foregroundStyle(GetColor.accent)
                .padding(ButtonT.IconPaddingT.large)
                .frame(
                    maxWidth: infinite ? ButtonT.WidthT.infinite : ButtonT.WidthT.medium,
                    maxHeight: ButtonT.HeightT.small
                )
        }
    }
}
