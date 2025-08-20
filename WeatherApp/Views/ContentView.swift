//
//  ContentView.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showingError = false
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                // Search section
                searchSection
                
                // Main content
                if viewModel.isLoading {
                    LoadingView()
                        .transition(.opacity.combined(with: .scale))
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        Task {
                            await viewModel.searchWeather()
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
                } else if let weather = viewModel.weather {
                    weatherContent(weather)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    welcomeSection
                        .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        let defaultLight = [Color.blue, Color.purple]
        let defaultDark = [Color(.systemIndigo), Color(.black)]
        let colors = viewModel.gradientColors.isEmpty ? (colorScheme == .dark ? defaultDark : defaultLight) : viewModel.gradientColors
        return LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            // App title
            Text("Weather App")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 18))
                
                TextField("Enter city name...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .onSubmit {
                        Task {
                            await viewModel.searchWeather()
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.2))
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // Search button
            Button(action: {
                Task {
                    await viewModel.searchWeather()
                }
            }) {
                Text("Search")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.2))
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .disabled(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
        }
        .padding(.bottom, 30)
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: 20) {
            WeatherIconView(weatherType: .clear, size: 100)
            
            Text("Welcome to Weather App")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Enter a city name above to get current weather and 5-day forecast")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Demo button for testing
            Button(action: {
                viewModel.loadMockData()
            }) {
                Text("Try Demo Data")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Weather Content
    private func weatherContent(_ weather: WeatherResponse) -> some View {
        ScrollView {
            VStack(spacing: 30) {
                // Current weather
                currentWeatherSection(weather)
                
                // Weather details
                weatherDetailsSection(weather)
                
                // 5-day forecast
                if !viewModel.dailyForecast.isEmpty {
                    forecastSection
                }
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Current Weather Section
    private func currentWeatherSection(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 20) {
            // City name
            VStack(spacing: 4) {
                Text(weather.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(weather.sys.country)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Weather icon and temperature
            HStack(spacing: 20) {
                WeatherIconView(
                    weatherType: weather.weather.first?.weatherType ?? .clear,
                    size: 80
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.formatTemperature(weather.main.temp))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Feels like
            Text("Feels like \(viewModel.formatTemperature(weather.main.feelsLike))")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Weather Details Section
    private func weatherDetailsSection(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 16) {
            Text("Weather Details")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                weatherDetailCard(
                    icon: "thermometer",
                    title: "Min/Max",
                    value: "\(viewModel.formatTemperature(weather.main.tempMin)) / \(viewModel.formatTemperature(weather.main.tempMax))"
                )
                
                weatherDetailCard(
                    icon: "humidity",
                    title: "Humidity",
                    value: viewModel.formatHumidity(weather.main.humidity)
                )
                
                weatherDetailCard(
                    icon: "wind",
                    title: "Wind Speed",
                    value: viewModel.formatWindSpeed(weather.wind.speed)
                )
                
                weatherDetailCard(
                    icon: "eye",
                    title: "Visibility",
                    value: "\(weather.visibility / 1000) km"
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Weather Detail Card
    private func weatherDetailCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.8))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
    
    // MARK: - Forecast Section
    private var forecastSection: some View {
        VStack(spacing: 16) {
            Text("5-Day Forecast")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.dailyForecast.prefix(5), id: \.id) { forecastItem in
                        ForecastRowView(
                            forecastItem: forecastItem,
                            viewModel: viewModel
                        )
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ContentView()
}
