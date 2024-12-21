//
//  WaterRippleGameView.swift
//  DuckChase
//
//  Created by Sagar Dagdu on 21/12/24.
//

import SwiftUI

struct WaterRippleGameView: View {
    @State private var ripples: [RippleEffect] = []
    @State private var waterPatches: [WaterPatch] = []
    @State private var ducks: [Duck] = []
    @State private var score: Int = 0
    @State private var missCount: Int = 0
    @State private var gameTime: Double = 0
    @State private var splashScale: CGFloat = 0
    @State private var isGameOver = false
    
    private let totalMissesAllowed = 20
    
    @Environment(\.colorScheme) var colorScheme
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    let duckTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var difficultyMultiplier: Double {
        2.0 + (gameTime / 60.0)
    }
    
    var rippleColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var lightPatchColor: Color {
        colorScheme == .dark ? .white : Color.blue.opacity(0.4)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.35),
                                    Color.blue.opacity(0.45)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    ForEach(waterPatches) { patch in
                        Circle()
                            .fill(patch.isLight ? lightPatchColor.opacity(patch.opacity) : Color.blue.opacity(patch.opacity))
                            .frame(width: patch.size, height: patch.size)
                            .position(patch.position)
                            .blur(radius: patch.size / 3)
                    }
                    
                    WaterMeshOverlay()
                        .opacity(0.1)
                    
                    ForEach(ripples) { ripple in
                        ForEach(0..<ripple.count) { index in
                            Circle()
                                .stroke(
                                    rippleColor.opacity(ripple.opacity * (1 - Double(index) / Double(ripple.count))),
                                    lineWidth: 1
                                )
                                .scaleEffect(ripple.scale + CGFloat(index) * 0.1)
                                .position(ripple.position)
                                .blur(radius: 0.3)
                        }
                    }
                    
                    if !isGameOver {
                        ForEach(ducks) { duck in
                            ZStack {
                                Circle()
                                    .stroke(rippleColor, lineWidth: 2)
                                    .scaleEffect(duck.isDisappearing ? 2 : 0)
                                    .opacity(duck.isDisappearing ? 0 : 1)
                                
                                Text("🦆")
                                    .font(.system(size: 50))
                                    .scaleEffect(duck.isDisappearing ? 0 : duck.scale)
                                    .opacity(duck.isDisappearing ? 0 : 1)
                            }
                            .position(duck.position)
                            .onTapGesture {
                                hitDuck(duck)
                            }
                            .animation(.easeOut(duration: 0.3), value: duck.isDisappearing)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("Misses: \(missCount)/\(totalMissesAllowed)")
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                            Text("Score: \(score)")
                                .font(.title2)
                                .padding()
                        }
                        Spacer()
                        
                        Button(action: resetGame) {
                            Text("Reset Game")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    
                    if isGameOver {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        
                        GameOverDialog(score: score, onRestart: resetGame)
                    }
                }
                .onAppear {
                    initializeWaterPatches()
                }
                .onReceive(timer) { _ in
                    if !isGameOver {
                        gameTime += 0.05
                        updateWaterPatches()
                        updateRipples()
                        updateDucks()
                    }
                }
                .onReceive(duckTimer) { _ in
                    if !isGameOver {
                        let duckCount = Int(difficultyMultiplier)
                        for _ in 0..<duckCount {
                            spawnDuck(in: geometry)
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            createRipple(at: value.location, intensity: Double.random(in: 0.3...1.0))
                        }
                )
            }
        }
    }
    
    private func spawnDuck(in geometry: GeometryProxy) {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let safeAreaInsets = windowScene?.windows.first?.safeAreaInsets ?? .zero
        let topPadding = safeAreaInsets.top + 100
        let position = CGPoint(
            x: CGFloat.random(in: 50...(geometry.size.width - 50)),
            y: CGFloat.random(in: topPadding...(geometry.size.height - safeAreaInsets.bottom - 100))
        )
        
        let lifetime = Double.random(in: 2...5) / difficultyMultiplier
        ducks.append(Duck(position: position, lifetime: lifetime))
    }
    
    private func updateDucks() {
        if isGameOver {
            ducks.removeAll()
            return
        }
        
        for index in ducks.indices.reversed() {
            ducks[index].lifetime -= 0.05
            if ducks[index].lifetime <= 0 {
                if !ducks[index].isDisappearing {
                    missCount += 1
                    if missCount >= totalMissesAllowed {
                        isGameOver = true
                        return
                    }
                }
                ducks.remove(at: index)
            } else if ducks[index].isDisappearing {
                ducks.remove(at: index)
            }
        }
    }
    
    private func hitDuck(_ duck: Duck) {
        if let index = ducks.firstIndex(where: { $0.id == duck.id }) {
            score += 1
            ducks[index].isDisappearing = true
            createRipple(at: duck.position, intensity: 1.0)
        }
    }
    
    private func resetGame() {
        score = 0
        missCount = 0
        gameTime = 0
        ducks.removeAll()
        isGameOver = false
    }
    
    private func createRipple(at position: CGPoint, intensity: Double) {
        let rippleCount = Int(intensity * 5) + 3
        let ripple = RippleEffect(
            position: position,
            intensity: intensity,
            count: rippleCount
        )
        ripples.append(ripple)
        
        let lightPatch = WaterPatch(
            position: position,
            size: 100 * intensity,
            opacity: 0.4,
            lifetime: 100,
            isLight: true
        )
        waterPatches.append(lightPatch)
        
        let generator = UIImpactFeedbackGenerator(style: intensity > 0.5 ? .heavy : .light)
        generator.impactOccurred(intensity: intensity)
    }
    
    private func initializeWaterPatches() {
        for _ in 0..<30 {
            waterPatches.append(WaterPatch.random())
        }
    }
    
    private func updateWaterPatches() {
        for index in waterPatches.indices {
            waterPatches[index].opacity += CGFloat.random(in: -0.01...0.01)
            waterPatches[index].opacity = max(0.05, min(0.2, waterPatches[index].opacity))
            
            waterPatches[index].position.x += CGFloat.random(in: -1...1)
            waterPatches[index].position.y += CGFloat.random(in: -1...1)
            
            if waterPatches[index].lifetime <= 0 {
                waterPatches[index] = WaterPatch.random()
            }
            waterPatches[index].lifetime -= 1
        }
    }
    
    private func updateRipples() {
        for index in ripples.indices {
            ripples[index].scale += 0.05
            ripples[index].opacity -= 0.01
        }
        ripples.removeAll { $0.opacity <= 0 }
    }
}

#Preview {
    WaterRippleGameView()
}
