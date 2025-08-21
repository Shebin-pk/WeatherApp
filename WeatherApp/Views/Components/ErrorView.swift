//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(Color("IconTint"))
                .shadow(color: Color("PrimaryShadow"), radius: 2, x: 0, y: 1)
            
            // Error title
            Text("Oops! Something went wrong")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.center)
            
            // Error message
            Text(errorMessage)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Retry button
            Button(action: onRetry) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                    Text("Try Again")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("TextPrimary"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color("CardBackground"))
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color("StrokeColor"), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("StrokeColor"), lineWidth: 1)
                )
        )
        .shadow(color: Color("PrimaryShadow").opacity(0.66), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ErrorView(
        errorMessage: "Unable to fetch weather data. Please check your internet connection and try again."
    ) {
        print("Retry tapped")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [Color.red, Color.orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
} 