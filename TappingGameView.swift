//
//  TappingGameView.swift
//  Chiron
//
//  Created by ak on 2/22/25.
//

import SwiftUI

struct TappingGameView: View {
    @State private var dots: [FallingDot] = []
    @State private var score: Int = 0
    @State private var gameRunning = false
    @State private var gameOver = false
    @State private var showInstructions = true
    @State private var showPauseMenu = false
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "HighScore")
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Score: \(score)")
                        .font(.custom("San Francisco", size: 26))
                        .foregroundColor(.pink.opacity(0.7))
                        .padding()
                    
                    Spacer()
                    
                    // Button that lets the user pause or unpause the game
                    Button(action: {
                        if gameRunning {
                            gameRunning = false
                            showPauseMenu = true
                        } else {
                            gameRunning = true
                            showPauseMenu = false
                            moveDots() // Resume movement
                            spawnDot() // Resume spawning dots
                        }
                        
                    }) {
                        Image(systemName: gameRunning ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.pink.opacity(0.7))
                            .padding()
                    }
                    
                    // Button to show the game instructions pop-up
                    Button(action: {
                        showInstructions = true
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.pink.opacity(0.7))
                            .padding(.trailing, 15)
                    }
                    
                }
                .padding()
                
                ZStack {
                    ForEach(dots) { dot in
                        Circle()
                            .fill(dot.color)
                            .frame(width: dot.size, height: dot.size)
                            .shadow(color: dot.color.opacity(0.5), radius: 10) // Soft glow effect
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 2)
                            )
                            .position(dot.position)
                            .scaleEffect(dot.isTapped ? 1.1 : 1.0)
                            .opacity(dot.isTapped ? 0 : 1) // Fade out when tapped on
                            .animation(.easeOut(duration: 0.3), value: dot.isTapped)
                            .onTapGesture {
                                tapDot(dot)
                            }
                        
                        
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
            }
            
            // Show this pop-up if the game is paused
            if showPauseMenu {
                VStack(spacing: 15) {
                    Text("Game Paused")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.pink.opacity(0.7))
                        .padding()
                    
                    // User can press this button to resume the game
                    Button("Resume Game") {
                        showPauseMenu = false // Make the pause menu disappear
                        gameRunning = true
                        moveDots() // Resume dot movement
                        spawnDot() // Keep spawning dots
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.pink.opacity(0.7))
                    .cornerRadius(10)
                    
                    // User can press this button to restart the game
                    Button("Restart Game") {
                        showPauseMenu = false
                        startGame()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.pink.opacity(0.7))
                    .cornerRadius(10)
                    
                }
                .frame(width: 300)
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(20)
                .shadow(color: Color.pink.opacity(0.3), radius: 10)
            }
            
            // Show this pop-up if the game is over
            if gameOver {
                ZStack {
                    VStack(spacing: 15) {
                        Text("Game Over")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                        
                        Text("High Score: \(highScore)") // Show stored high score
                            .font(.title2)
                            .padding(.top, 10)
                        
                        Text("Your score: \(score)") // Show high score
                            .font(.title2)
                            .padding(.bottom, 10)
                        
                        // Button lets the user restart the game after losing
                        Button(action: {
                            gameOver = false // Hide pop-up
                            startGame() // Restart the game
                        }) {
                            Text("Restart Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.pink.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .frame(width: 300)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .shadow(color: Color.pink.opacity(0.3), radius: 10)
                }
            }
            
            if showInstructions {
                ZStack {
                    
                    VStack(spacing: 15) {
                        Text("How to Play")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.pink)
                        
                        Text("Tap the falling dots before they reach the bottom! Each pop earns points.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Dots fall faster as your score increases. Be quick!")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("If a dot reaches the bottom, the game ends.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button(action: {
                            showInstructions = false // Dismiss instructions & start game
                            gameRunning = true
                            moveDots()
                            spawnDot()
                        }) {
                            Text("Start Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: 200)
                                .background(Color.pink.opacity(0.6))
                                .cornerRadius(10)
                        }
                        .padding(.top, 10)
                    }
                    .frame(width: 300)
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .cornerRadius(20)
                    .shadow(color: Color.pink.opacity(0.3), radius: 10)
                }
            }
        }
        .onAppear {
            gameRunning = false
        }
    }
    
    struct FallingDot: Identifiable {
        let id = UUID()
        var position: CGPoint
        let size: CGFloat
        let speed: CGFloat
        let color: Color
        var isTapped: Bool = false
    }
    
    func startGame() {
        score = 0
        dots.removeAll()
        gameRunning = true
        gameOver = false
        spawnDot()
    }
    
    func spawnDot() {
        guard gameRunning else { return }
        
        let randomX = CGFloat.random(in: 50...(screenWidth - 50))
        let dotSize = CGFloat.random(in: 40...100)
        let speed = CGFloat(2.0 + Double(score) * 0.005) // Dots get faster as score increases
        
        let newDot = FallingDot(
            position: CGPoint(x: randomX, y: 0), // Start above the screen
            size: dotSize,
            speed: speed,
            color: Color.random()
        )
        
        dots.append(newDot)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + max(0.8 - Double(score) * 0.02, 0.3)) {
            if gameRunning {
                spawnDot()
            }
        }
        
        moveDots()
    }
    
    func moveDots() {
        guard gameRunning else { return }
        
        for i in dots.indices {
            dots[i].position.y += dots[i].speed
        }
        
        dots.removeAll { dot in
            if dot.position.y > screenHeight { // If dot reaches the bottom, end the game
                gameOver = true
                gameRunning = false
                
                // Check if score is greater than the all-time high score
                if score > highScore {
                    highScore = score // Update the high score
                    UserDefaults.standard.set(highScore, forKey: "HighScore") // Save new high score
                }
                return true
            }
            return false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            if gameRunning {
                moveDots()
            }
        }
    }
    
    func tapDot(_ dot: FallingDot) {
        guard gameRunning else { return }
        
        if let index = dots.firstIndex(where: { $0.id == dot.id }) {
            dots[index].isTapped = true // Trigger animation
            
            // Delay removal to allow squish effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dots.remove(at: index)
                score += 1
            }
        }
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0.9...1.0),
            green: Double.random(in: 0.4...0.7),
            blue: Double.random(in: 0.5...0.8)
        )
    }
}


#Preview {
    TappingGameView()
}
