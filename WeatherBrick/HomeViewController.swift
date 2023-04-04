//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

let reachability = try! Reachability()

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var brickImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var typeOfWeatherLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var brickImageTopConstraint: NSLayoutConstraint!
    
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
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = InfoButton.bounds
        gradientLayer.colors = [UIColor(red: 1, green: 0.6, blue: 0.38, alpha: 1).cgColor, UIColor(red: 0.98, green: 0.31, blue: 0.11, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        InfoButton.layer.insertSublayer(gradientLayer, at: 0)
        
        let cornerRadius: CGFloat = 20.0
        InfoButton.layer.cornerRadius = cornerRadius
        InfoButton.clipsToBounds = true
        InfoButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        locationButton.setImage(locationImageView.image, for: .normal)
        searchButton.setImage(searchImageView.image, for: .normal)

    }
    
    @IBAction func goToInfo(_ sender: Any) {
        performSegue(withIdentifier: "goToInfo", sender: nil)
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        brickImageTopConstraint.constant += 5
        fetchData()
        brickImageTopConstraint.constant -= 5
        sender.endRefreshing()
    }
    
    @IBAction func pushToLocationButton(_ sender: Any) {
        refresh(myRefreshControl)
    }
    
    @IBAction func pushToSearchButton(_ sender: Any) {
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
        let locationText = NSMutableAttributedString(string: "")
        locationText.append(NSAttributedString(string: " \(cityName), \(countryCode) "))
        locationLabel.attributedText = locationText
        updateBrickImage(with: weatherType)
    }
    
    func updateBrickImage(with weatherType: String) {
        
        switch weatherType {
        case "Rain", "Drizzle":
            brickImage.image = UIImage(named: "image_stone_wet")
        case "light snow", "snow":
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

