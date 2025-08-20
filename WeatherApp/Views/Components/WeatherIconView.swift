//
//  WeatherIconView.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import SwiftUI

struct WeatherIconView: View {
    let weatherType: WeatherType
    let size: CGFloat
    
    @State private var isAnimating = false
    
    var body: some View {
        Image(systemName: weatherType.iconName)
            .font(.system(size: size))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .rotationEffect(.degrees(rotationAngle))
            .offset(x: horizontalOffset, y: verticalOffset)
            .animation(
                Animation.easeInOut(duration: animationDuration)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
    
    // MARK: - Animation Properties
    private var rotationAngle: Double {
        switch weatherType {
        case .clear:
            return isAnimating ? 360 : 0
        case .cloudy, .foggy:
            return isAnimating ? 5 : -5
        case .rainy, .stormy:
            return isAnimating ? 10 : -10
        case .snowy:
            return isAnimating ? 15 : -15
        }
    }
    
    private var horizontalOffset: CGFloat {
        switch weatherType {
        case .clear:
            return 0
        case .cloudy, .foggy:
            return isAnimating ? 3 : -3
        case .rainy, .stormy:
            return isAnimating ? 5 : -5
        case .snowy:
            return isAnimating ? 2 : -2
        }
    }
    
    private var verticalOffset: CGFloat {
        switch weatherType {
        case .clear:
            return 0
        case .cloudy, .foggy:
            return isAnimating ? 2 : -2
        case .rainy, .stormy:
            return isAnimating ? 3 : -3
        case .snowy:
            return isAnimating ? 4 : -4
        }
    }
    
    private var animationDuration: Double {
        switch weatherType {
        case .clear:
            return 20.0 // Slow rotation for sun
        case .cloudy, .foggy:
            return 4.0
        case .rainy, .stormy:
            return 2.0
        case .snowy:
            return 3.0
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        WeatherIconView(weatherType: .clear, size: 60)
        WeatherIconView(weatherType: .cloudy, size: 60)
        WeatherIconView(weatherType: .rainy, size: 60)
        WeatherIconView(weatherType: .snowy, size: 60)
    }
    .padding()
    .background(Color.blue)
} 
