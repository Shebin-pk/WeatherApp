//
//  LoadingView.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated weather icon placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                        startPoint: isAnimating ? .topLeading : .bottomTrailing,
                        endPoint: isAnimating ? .bottomTrailing : .topLeading
                    )
                )
                .frame(width: 80, height: 80)
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Loading text
            Text("Loading weather data...")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .opacity(isAnimating ? 0.7 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Shimmer effect for content placeholders
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.2)
                                ],
                                startPoint: isAnimating ? .leading : .trailing,
                                endPoint: isAnimating ? .trailing : .leading
                            )
                        )
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
} 