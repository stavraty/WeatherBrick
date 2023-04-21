//
//  WeatherData.swift
//  WeatherBrick
//
//  Created by AS on 16.03.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import UIKit

struct WeatherModel: Codable {
    let name: String
    let sys: Sys
    let weather: [Weather]
    let main: Main
}

struct Sys: Codable {
    let country: String
}

struct Weather: Codable {
    let description: String
}

struct Main: Codable {
    let temp: Double
}
