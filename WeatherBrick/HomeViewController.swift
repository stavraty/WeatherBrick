//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
//import Reachability

let reachability = try! Reachability()

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var brickImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var typeOfWeatherLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    let locationImageView = UIImageView(image: UIImage(named: "icon_location"))
    let searchImageView = UIImageView(image: UIImage(named: "icon_search"))

    let locationManager = CLLocationManager()
    var location: CLLocation!
    
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.refreshControl = myRefreshControl
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func goToInfo(_ sender: Any) {
        performSegue(withIdentifier: "goToInfo", sender: nil)
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        fetchData()
        
        temperatureLabel.text = "..."
        typeOfWeatherLabel.text = "..."
        locationLabel.text = "..."
        brickImage.image = UIImage(named: "image_no_internet")
        
        sender.endRefreshing()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let refreshControl = scrollView.subviews.first(where: { $0 is UIRefreshControl }) as? UIRefreshControl
        let offsetY = scrollView.contentOffset.y
        
        if offsetY < -refreshControl!.frame.height {
            refreshControl?.tintColor = .green
        } else {
            refreshControl?.tintColor = .white
        }
    }
    
    func fetchData() {
        let apiKey = "d09438c0cc92bf784485c365b0ec1c93"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }

    func updateUI(with weatherData: WeatherData) {
        
        let weatherType = weatherData.weather.first?.description ?? ""
        typeOfWeatherLabel.text = weatherType
        
        let temperature = Int(weatherData.main.temp - 273.15)
        temperatureLabel.text = "\(temperature)°"
        
        let cityName = weatherData.name
        let countryCode = weatherData.sys.country
        //locationLabel.text = " \(cityName), \(countryCode) "
        let locationText = NSMutableAttributedString(string: "")
        if #available(iOS 13.0, *) {
            locationText.append(NSAttributedString(attachment: NSTextAttachment(image: locationImageView.image!)))
        } else {
        }
        locationText.append(NSAttributedString(string: " \(cityName), \(countryCode) "))
        if #available(iOS 13.0, *) {
            locationText.append(NSAttributedString(attachment: NSTextAttachment(image: searchImageView.image!)))
        } else {
        }
        locationLabel.attributedText = locationText
        updateBrickImage(with: weatherType)
        
//        if reachability.connection == .unavailable {
//            brickImage.image = UIImage(named: "image_stone_snow")
//        }
    }
    
    func updateBrickImage(with weatherType: String) {
        
        switch weatherType {
        case "Rain", "Drizzle":
            brickImage.image = UIImage(named: "image_stone_wet")
        case "Snow":
            brickImage.image = UIImage(named: "image_stone_snow")
        case "Fog", "Mist":
            brickImage.image = UIImage(named: "image_stone_fog")
        case "Clear":
            brickImage.image = UIImage(named: "image_stone_normal")
        case "Hot":
            brickImage.image = UIImage(named: "image_stone_cracks")
        default:
            brickImage.image = UIImage(named: "image_stone_normal")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationManager.stopUpdatingLocation()
        
        let apiKey = "d09438c0cc92bf784485c365b0ec1c93"
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

