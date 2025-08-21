//
//  City.swift
//  WeatherApp
//
//  Created by Shebin PK on 20/08/25.
//

import Foundation

struct City: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
    
    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
}