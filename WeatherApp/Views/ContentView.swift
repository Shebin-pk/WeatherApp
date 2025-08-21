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
            colorScheme == .dark ? Color("BackgroundDark") : Color("BackgroundLight")
            
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
        let defaultLight = [Color("BackgroundStartLight"), Color("BackgroundEndLight")].compactMap { $0 }
        let defaultDark = [Color("BackgroundStartDark"), Color("BackgroundEndDark")].compactMap { $0 }
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
                .foregroundColor(Color("TextPrimary"))
                .shadow(color: Color("PrimaryShadow"), radius: 2, x: 0, y: 1)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("TextSecondary"))
                    .font(.system(size: 18))
                
                TextField("Enter city name...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .foregroundColor(Color("TextPrimary"))
                    .onSubmit {
                        Task {
                            await viewModel.searchWeather()
                        }
                    }
                    .onChange(of: viewModel.searchText) { newValue in
                        viewModel.onSearchTextChanged(newValue)
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("TextSecondary"))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color("CardBackground"))
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color("StrokeColor"), lineWidth: 1)
                    )
            )
            // Suggestions dropdown
            if viewModel.isShowingSuggestions {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.citySuggestions) { city in
                        Button {
                            viewModel.selectCity(city)
                        } label: {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(Color("IconTint"))
                                Text(city.displayName)
                                    .foregroundColor(Color("TextPrimary"))
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if city.id != viewModel.citySuggestions.last?.id {
                            Divider()
                                .background(Color("StrokeColor"))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("CardBackground"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("StrokeColor"), lineWidth: 1)
                        )
                )
            }
            
            // Search button
            Button(action: {
                Task {
                    await viewModel.searchWeather()
                }
            }) {
                Text("Search")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("TextPrimary"))
                    .frame(maxWidth: .infinity)
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
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.center)
            
            Text("Enter a city name above to get current weather and 5-day forecast")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            // Demo button for testing
            Button(action: {
                viewModel.loadMockData()
            }) {
                Text("Try Demo Data")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("StrokeColor"), lineWidth: 1)
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
                    .foregroundColor(Color("TextPrimary"))
                
                Text(weather.sys.country)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("TextSecondary"))
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
                        .foregroundColor(Color("TextPrimary"))
                    
                    Text(weather.weather.first?.description.capitalized ?? "")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))
                }
            }
            
            // Feels like
            Text("Feels like \(viewModel.formatTemperature(weather.main.feelsLike))")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color("TextSecondary"))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("CardBackground"))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("StrokeColor"), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Weather Details Section
    private func weatherDetailsSection(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 16) {
            Text("Weather Details")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
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
                .fill(Color("CardBackground"))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("StrokeColor"), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Weather Detail Card
    private func weatherDetailCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color("IconTint"))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("TextSecondary"))
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
        )
    }
    
    // MARK: - Forecast Section
    private var forecastSection: some View {
        VStack(spacing: 16) {
            Text("5-Day Forecast")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("TextPrimary"))
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
                .fill(Color("CardBackground"))
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("StrokeColor"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ContentView()
}
