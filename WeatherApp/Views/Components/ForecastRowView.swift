//
//  ForecastRowView.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import SwiftUI

struct ForecastRowView: View {
    let forecastItem: ForecastItem
    let viewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Day name
            Text(forecastItem.dayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("TextPrimary"))
                .lineLimit(1)
            
            // Weather icon
            WeatherIconView(
                weatherType: forecastItem.weather.first?.weatherType ?? .clear,
                size: 30
            )
            
            // Temperature
            Text(viewModel.formatTemperature(forecastItem.main.temp))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
            
            // Weather description
            Text(forecastItem.weather.first?.description.capitalized ?? "")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 120)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("StrokeColor"), lineWidth: 1)
                )
        )
        .shadow(color: Color("PrimaryShadow").opacity(0.33), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let mockItem = ForecastItem(
        dt: 1640995200,
        main: MainWeather(
            temp: 25.0,
            feelsLike: 26.0,
            tempMin: 20.0,
            tempMax: 30.0,
            pressure: 1013,
            humidity: 65
        ),
        weather: [
            WeatherCondition(
                id: 800,
                main: "Clear",
                description: "clear sky",
                icon: "01d"
            )
        ],
        clouds: Clouds(all: 20),
        wind: Wind(speed: 5.0, deg: 180),
        visibility: 10000,
        pop: 0.1,
        dtTxt: "2024-01-01 12:00:00"
    )
    
    return ForecastRowView(
        forecastItem: mockItem,
        viewModel: WeatherViewModel()
    )
    .padding()
    .background(Color.blue)
} 