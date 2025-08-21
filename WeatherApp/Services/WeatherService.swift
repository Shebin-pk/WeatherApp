//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import Foundation

// MARK: - Weather Service Error
enum WeatherServiceError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode weather data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

// MARK: - Weather Service
class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let geoURL = "https://api.openweathermap.org/geo/1.0"
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with your OpenWeatherMap API key 
    
    private init() {}

    // MARK: - Geocoding (City Suggestions)
    func searchCities(_ query: String, limit: Int = 5) async throws -> [City] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(geoURL)/direct?q=\(encoded)&limit=\(limit)&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { throw WeatherServiceError.invalidURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse else { throw WeatherServiceError.invalidResponse }
            switch http.statusCode {
            case 200:
                let result = try JSONDecoder().decode([City].self, from: data)
                return result
            case 401:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key is invalid or not activated. Please check your OpenWeatherMap API key."]))
            default:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(http.statusCode)"]))
            }
        } catch let e as WeatherServiceError {
            throw e
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
    
    // MARK: - Fetch Current Weather
    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let urlString = "\(baseURL)/weather?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.invalidResponse
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                return weatherResponse
            case 401:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key is invalid or not activated. Please check your OpenWeatherMap API key."]))
            case 404:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found. Please check the city name."]))
            case 429:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 429, userInfo: [NSLocalizedDescriptionKey: "API rate limit exceeded. Please try again later."]))
            default:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"]))
            }
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
    
    // MARK: - Fetch 5-Day Forecast
    func fetchForecast(for city: String) async throws -> ForecastResponse {
        let urlString = "\(baseURL)/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.invalidResponse
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200:
                let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                return forecastResponse
            case 401:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 401, userInfo: [NSLocalizedDescriptionKey: "API key is invalid or not activated. Please check your OpenWeatherMap API key."]))
            case 404:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 404, userInfo: [NSLocalizedDescriptionKey: "City not found. Please check the city name."]))
            case 429:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: 429, userInfo: [NSLocalizedDescriptionKey: "API rate limit exceeded. Please try again later."]))
            default:
                throw WeatherServiceError.networkError(NSError(domain: "API", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"]))
            }
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
    
    // MARK: - Mock Data for Demo
    static func mockWeatherResponse() -> WeatherResponse {
        return WeatherResponse(
            weather: [
                WeatherCondition(
                    id: 800,
                    main: "Clear",
                    description: "clear sky",
                    icon: "01d"
                )
            ],
            main: MainWeather(
                temp: 25.0,
                feelsLike: 26.0,
                tempMin: 20.0,
                tempMax: 30.0,
                pressure: 1013,
                humidity: 65
            ),
            name: "London",
            sys: SystemInfo(
                country: "GB",
                sunrise: 1640995200,
                sunset: 1641027600
            ),
            wind: Wind(speed: 5.0, deg: 180),
            clouds: Clouds(all: 20),
            visibility: 10000,
            dt: 1640995200
        )
    }
    
    static func mockForecastResponse() -> ForecastResponse {
        let mockItems = (0..<40).map { index in
            ForecastItem(
                dt: 1640995200 + (index * 3600 * 3),
                main: MainWeather(
                    temp: Double.random(in: 15...30),
                    feelsLike: Double.random(in: 15...30),
                    tempMin: Double.random(in: 10...25),
                    tempMax: Double.random(in: 20...35),
                    pressure: 1013,
                    humidity: Int.random(in: 40...80)
                ),
                weather: [
                    WeatherCondition(
                        id: [800, 801, 802, 803, 804].randomElement()!,
                        main: ["Clear", "Clouds", "Rain"].randomElement()!,
                        description: "weather description",
                        icon: "01d"
                    )
                ],
                clouds: Clouds(all: Int.random(in: 0...100)),
                wind: Wind(speed: Double.random(in: 0...15), deg: Int.random(in: 0...360)),
                visibility: 10000,
                pop: Double.random(in: 0...1),
                dtTxt: "2024-01-01 12:00:00"
            )
        }
        
        return ForecastResponse(
            list: mockItems,
            city: ForecastCity(
                id: 2643743,
                name: "London",
                country: "GB",
                population: 8908081,
                timezone: 0,
                sunrise: 1640995200,
                sunset: 1641027600,
                coord: Coordinates(lat: 51.5074, lon: -0.1278)
            )
        )
    }
} 
