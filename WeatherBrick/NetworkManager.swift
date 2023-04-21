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

    func getWeather(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? UnknownError()))
                return
            }
            completion(.success(data))
        }
        task.resume()
    }
    
    func fetchWeatherData(location: CLLocation?, city: String?, completion: @escaping (Result<WeatherModel, Error>) -> Void) {
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
            getWeather(from: url) { result in
                switch result {
                case .success(let data):
                    do {
                        let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                        completion(.success(weatherData))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(UnknownError()))
        }
    }
}

struct UnknownError: Error {}

