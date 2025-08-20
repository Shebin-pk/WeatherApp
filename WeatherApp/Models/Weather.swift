//
//  Weather.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import Foundation

// MARK: - Weather Response
struct WeatherResponse: Codable {
    let weather: [WeatherCondition]
    let main: MainWeather
    let name: String
    let sys: SystemInfo
    let wind: Wind
    let clouds: Clouds
    let visibility: Int
    let dt: Int
}

// MARK: - Weather Condition
struct WeatherCondition: Codable, Identifiable {
    let id: Int
    let main: String
    let description: String
    let icon: String
    
    var weatherType: WeatherType {
        switch main.lowercased() {
        case "clear":
            return .clear
        case "clouds":
            return .cloudy
        case "rain", "drizzle":
            return .rainy
        case "snow":
            return .snowy
        case "thunderstorm":
            return .stormy
        case "mist", "fog", "haze":
            return .foggy
        default:
            return .clear
        }
    }
}

// MARK: - Main Weather Data
struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

// MARK: - System Info
struct SystemInfo: Codable {
    let country: String
    let sunrise: Int
    let sunset: Int
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Weather Type Enum
enum WeatherType: String, CaseIterable {
    case clear = "Clear"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case stormy = "Stormy"
    case foggy = "Foggy"
    
    var iconName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .cloudy:
            return "cloud.fill"
        case .rainy:
            return "cloud.rain.fill"
        case .snowy:
            return "cloud.snow.fill"
        case .stormy:
            return "cloud.bolt.rain.fill"
        case .foggy:
            return "cloud.fog.fill"
        }
    }
    
    var gradientColors: [String] {
        switch self {
        case .clear:
            return ["#FFD700", "#FFA500"]
        case .cloudy:
            return ["#87CEEB", "#B0C4DE"]
        case .rainy:
            return ["#4682B4", "#708090"]
        case .snowy:
            return ["#F0F8FF", "#E6E6FA"]
        case .stormy:
            return ["#2F4F4F", "#696969"]
        case .foggy:
            return ["#D3D3D3", "#A9A9A9"]
        }
    }
} 