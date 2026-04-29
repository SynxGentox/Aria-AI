//
//  ViewValues.swift
//  Expense Tracker
//
//  Created by Aryan Verma on 31/03/26.
//

import SwiftUI

struct FontT {
    static let secondary: CGFloat = UIFontMetrics(forTextStyle: .body).scaledValue(for: 14)
    static let primary: CGFloat = UIFontMetrics(forTextStyle: .title2).scaledValue(for: 20)
    static let title: CGFloat = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: 30)
    static let amount: CGFloat = UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: 48)
}

enum ButtonT {
    struct IconPaddingT {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
    
    struct WidthT {
        static let infinite: CGFloat = .infinity
        static let medium: CGFloat = 60
        static let large: CGFloat = 90
        static let small: CGFloat = 30
    }
    
    struct HeightT {
        static let medium: CGFloat = 60
        static let large: CGFloat = 90
        static let small: CGFloat = 30
    }
}
  
struct ShadowT {
    static let shadow: CGFloat = 8
    static let positionX: CGFloat = 8
    static let positionY: CGFloat = -8
}

enum CardT {
    
    struct MaterialT {
        static let thin: Material = .ultraThinMaterial
        static let regular: Material = .regularMaterial
        
    }
    
    struct HeightT {
        static let small: CGFloat = 60
        static let higherSmall: CGFloat = 80
        static let lowerMedium: CGFloat = 100
        static let medium: CGFloat = 120
        static let large: CGFloat = 180
        static let xLarge: CGFloat = 270
        static let infinity: CGFloat = .infinity
    }
    
    struct WidthT {
        static let small: CGFloat = 60
        static let higherSmall: CGFloat = 80
        static let lowerMedium: CGFloat = 100
        static let medium: CGFloat = 120
        static let large: CGFloat = 180
        static let infinity: CGFloat = .infinity
    }
    
    struct RadiusOrPaddingT {
        static let smoothRadius: CGFloat = 30
        static let sharpRadius: CGFloat = 8
        static let padding: CGFloat = 18
    }
    
}

struct GetColor {
    static let white =  Color.white
    static let black = Color.black
    static let accent = Color.accentColor
    static let primary = Color.primary
    static let green = Color(UIColor.systemGreen)
    static let sysBack = Color(UIColor.systemBackground)
    static let sysGray = Color(UIColor.systemGray6)
    static let grayStatic = Color.gray
    static let clear = Color.clear
    static let ariaBackground = Color("ariaBackground")  // #2A0F20
    static let ariaSurface = Color("ariaSurface")        // #F7EDE7
    static let ariaAccent = Color("ariaAccent")          // #A02570
    static let ariaWarm = Color("ariaWarm")              // #C4423A
}


