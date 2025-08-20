# WeatherApp – Modern iOS Weather App (SwiftUI, MVVM)

A clean, minimal, and responsive weather app for iOS built with SwiftUI and MVVM. It fetches real-time weather and a 5-day forecast and adapts its look to the current weather and system appearance (light/dark mode).

## Features

- **City search**: Type a city name and fetch live weather
- **Current conditions**: City, temperature (°C), description, and icon (SF Symbols)
- **5-day forecast**: Horizontal scroll with daily snapshots
- **Dynamic theming**: Gradient backgrounds change by weather type
- **Animations**: Subtle icon motion and smooth screen transitions
- **Loading & errors**: Shimmer/loading state and graceful error messages
- **Light/Dark mode**: Fully supports system appearance

## Tech Stack

- **Language**: Swift (5.9+)
- **UI**: SwiftUI
- **Architecture**: MVVM
- **Networking**: URLSession with async/await
- **Target**: iOS 16+
- **Dependencies**: Swift Package Manager only (no CocoaPods)


## Getting Started

### Requirements
- Xcode 15+
- iOS 16+ simulator or device

### Open the project
```bash
open WeatherApp.xcodeproj
```

### Configure your API key (OpenWeatherMap)
1. Create a free account at `https://openweathermap.org/api`
2. Copy your API key from your account’s API Keys page
3. In the project, open:
   - `WeatherApp/Services/WeatherService.swift`
4. Replace the placeholder string with your key if needed:
```swift
private let apiKey = "your_actual_api_key_here"
```
Notes:
- New keys may take 2–4 hours to activate. If you receive HTTP 401, wait and try again.
- Keep your API key private (avoid committing real keys to public repos).

### Run the app
- Select an iPhone simulator (e.g., iPhone 15)
- Press Cmd + R in Xcode

### Demo mode (no API key yet?)
On the welcome screen, tap “Try Demo Data” to load mock weather data and explore the UI.

## Usage
- Enter a city name (e.g., “Paris”) and tap “Search”
- View current conditions: temperature, summary, and animated icon
- Scroll the 5-day forecast horizontally
- Switch your device between light/dark mode to see adaptive styling


### Notes on Dark Mode
- Colors use semantic/adaptive variants where appropriate
- Background gradients shift based on weather type and current color scheme
- Avoid hardcoded black/white for text; prefer `Color.primary`/`secondary` when possible

## Customization
- Update gradient palettes per weather type in `WeatherType` (in `Models/Weather.swift`)
- Tweak icon animations in `WeatherIconView`
- Adjust card styles (corner radius, strokes, opacity) in component views

## Troubleshooting
- **401 Unauthorized**: Your API key is missing, invalid, or not yet activated. Wait a few hours after creating a new key.
- **No results**: Verify the city spelling (e.g., try “London”, “Paris”, “New York”).
- **Simulator issues**: Erase content/settings or try another simulator device.

## License
This project is licensed under the MIT License. See `LICENSE` for details.

## Acknowledgments
- OpenWeatherMap for the weather API
- Apple’s SF Symbols and SwiftUI
