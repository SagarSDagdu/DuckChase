//
//  Models.swift
//  DuckChase
//
//  Created by Sagar Dagdu on 21/12/24.
//

import SwiftUI

struct Duck: Identifiable {
    let id = UUID()
    var position: CGPoint
    var lifetime: Double
    var scale: CGFloat = 1.0
    var isDisappearing = false
}

struct RippleEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat = 0
    var opacity: Double = 0.3
    var intensity: Double
    let count: Int
}

struct WaterPatch: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: CGFloat
    var lifetime: Int
    var isLight: Bool = false
    
    static func random() -> WaterPatch {
        WaterPatch(
            position: CGPoint(
                x: CGFloat.random(in: -50...450),
                y: CGFloat.random(in: -50...450)
            ),
            size: CGFloat.random(in: 50...150),
            opacity: CGFloat.random(in: 0.05...0.2),
            lifetime: Int.random(in: 100...200)
        )
    }
}
