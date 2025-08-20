//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import Foundation
import SwiftUI

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var forecast: ForecastResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let weatherService = WeatherService.shared
    
    // MARK: - Search Weather
    func searchWeather() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a city name"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            async let weatherTask = weatherService.fetchWeather(for: searchText)
            async let forecastTask = weatherService.fetchForecast(for: searchText)
            
            let (weatherResult, forecastResult) = try await (weatherTask, forecastTask)
            
            self.weather = weatherResult
            self.forecast = forecastResult
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Load Mock Data for Testing
    func loadMockData() {
        weather = WeatherService.mockWeatherResponse()
        forecast = WeatherService.mockForecastResponse()
    }
    
    // MARK: - Clear Error
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Get Daily Forecast (5 days)
    var dailyForecast: [ForecastItem] {
        guard let forecast = forecast else { return [] }
        
        // Group by day and get the forecast for 12:00 PM each day
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: forecast.list) { item in
            calendar.startOfDay(for: item.date)
        }
        
        return groupedByDay.compactMap { (_, items) in
            // Find the forecast closest to 12:00 PM
            items.min { item1, item2 in
                let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: item1.date) ?? item1.date
                let noon2 = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: item2.date) ?? item2.date
                
                let diff1 = abs(item1.date.timeIntervalSince(noon))
                let diff2 = abs(item2.date.timeIntervalSince(noon2))
                
                return diff1 < diff2
            }
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Get Current Weather Type
    var currentWeatherType: WeatherType {
        weather?.weather.first?.weatherType ?? .clear
    }
    
    // MARK: - Get Gradient Colors
    var gradientColors: [Color] {
        let colors = currentWeatherType.gradientColors
        return colors.compactMap { Color(hex: $0) }
    }
    
    // MARK: - Format Temperature
    func formatTemperature(_ temp: Double) -> String {
        return "\(Int(round(temp)))°C"
    }
    
    // MARK: - Format Wind Speed
    func formatWindSpeed(_ speed: Double) -> String {
        return "\(Int(round(speed))) km/h"
    }
    
    // MARK: - Format Humidity
    func formatHumidity(_ humidity: Int) -> String {
        return "\(humidity)%"
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
