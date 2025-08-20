//
//  Forecast.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import Foundation

// MARK: - Forecast Response
struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: ForecastCity
}

// MARK: - Forecast Item
struct ForecastItem: Codable, Identifiable {
    let id = UUID()
    let dt: Int
    let main: MainWeather
    let weather: [WeatherCondition]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let dtTxt: String
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop
        case dtTxt = "dt_txt"
    }
    
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Forecast City
struct ForecastCity: Codable {
    let id: Int
    let name: String
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
    let coord: Coordinates
}

// MARK: - Coordinates
struct Coordinates: Codable {
    let lat: Double
    let lon: Double
} 