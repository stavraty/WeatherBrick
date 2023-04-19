//
//  NetworkManager.swift
//  WeatherBrick
//
//  Created by AS on 12.04.2023.
//  Copyright © 2023 VAndrJ. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkManager {
    
    private let apiKey = "d09438c0cc92bf784485c365b0ec1c93"

    func fetchWeatherData(location: CLLocation?, city: String?, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        var urlString = "https://api.openweathermap.org/data/2.5/weather?"
        if let location = location {
            urlString += "lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)"
        } else if let city = city?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "q=\(city)"
        } else {
            completion(.failure(UnknownError()))
            return
        }
        urlString += "&appid=\(apiKey)"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(.failure(error ?? UnknownError()))
                    return
                }
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            }
            task.resume()
        } else {
            completion(.failure(UnknownError()))
        }
    }
}

struct UnknownError: Error {}

