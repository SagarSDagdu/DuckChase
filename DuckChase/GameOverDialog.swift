//
//  GameOverDialog.swift
//  DuckChase
//
//  Created by Sagar Dagdu on 21/12/24.
//

import SwiftUI

struct GameOverDialog: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Final Score: \(score)")
                .font(.title2)
            
            Button(action: onRestart) {
                Text("Restart Game")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(30)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

#Preview {
    GameOverDialog(score: 100, onRestart: {})
}
