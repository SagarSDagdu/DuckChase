//
//  WaterMeshOverlay.swift
//  DuckChase
//
//  Created by Sagar Dagdu on 21/12/24.
//

import SwiftUI

struct WaterMeshOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let stepSize: CGFloat = 20
                for x in stride(from: 0, through: geometry.size.width, by: stepSize) {
                    for y in stride(from: 0, through: geometry.size.height, by: stepSize) {
                        let rect = CGRect(x: x, y: y, width: stepSize, height: stepSize)
                        path.addRect(rect)
                    }
                }
            }
            .stroke(Color.blue.opacity(0.1), lineWidth: 0.5)
        }
    }
}

#Preview {
    WaterMeshOverlay()
}
