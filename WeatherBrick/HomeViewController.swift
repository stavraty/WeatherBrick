//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

let reachability = try! Reachability()

class HomeViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var brickImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var typeOfWeatherLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    let locationImageView = UIImageView(image: UIImage(named: "icon_location"))
    let searchImageView = UIImageView(image: UIImage(named: "icon_search"))
    let locationManager = CLLocationManager()
    var location: CLLocation!
    let apiKey = "d09438c0cc92bf784485c365b0ec1c93"
    
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
        InfoButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 22)
        
        locationButton.setImage(locationImageView.image, for: .normal)
        searchButton.setImage(searchImageView.image, for: .normal)
        
        searchTextField.isHidden = true
        searchButton.addTarget(self, action: #selector(pushToSearchButton), for: .touchUpInside)
        
        searchTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        searchTextField.layer.shadowColor = UIColor.black.cgColor
        searchTextField.layer.shadowOpacity = 0.5
        searchTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchTextField.layer.shadowRadius = 2
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via wifi")
            }else{
                print("Reachable via cellular")
            }
        }
        
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            self.showAlert()
        }
        
        do {
            try reachability.startNotifier()
        }catch{
            print("unable to start notifier")
        }
        
        brickImage.addSubview(myRefreshControl)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        brickImage.isUserInteractionEnabled = true
        brickImage.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.brickImage.superview)

        switch gesture.state {
        case .changed:
            var transform = CGAffineTransform.identity
            if translation.y <= 30 {
                transform = CGAffineTransform(translationX: 0, y: translation.y)
            } else {
                transform = CGAffineTransform(translationX: 0, y: 30)
            }

            brickImage.transform = transform
        case .ended:
            if translation.y > 30 {
                    self.fetchData()
                }
        default:
            break
        }
    }

    @IBAction func goToInfo(_ sender: Any) {
        performSegue(withIdentifier: "goToInfo", sender: nil)
    }
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        fetchData()
        sender.endRefreshing()
    }
    
    @IBAction func pushToLocationButton(_ sender: Any) {
        myRefreshControl.beginRefreshing()
        refresh(myRefreshControl)
    }
    
    @IBAction func pushToSearchButton(_ sender: Any) {
        searchTextField.isHidden = false
        searchTextField.becomeFirstResponder()
    }
    
    func fetchData() {
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
    
    func searchForCity() {
        if let cityName = searchTextField.text?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)"
            if let url = URL(string: urlString) {
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
    }
    
    func updateWeatherData(for city: String) {
        let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription ?? "Unknown error", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                return
            }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
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
        
        UIView.animate(withDuration: 0.1, animations: {
            self.brickImage.transform = CGAffineTransform(translationX: 0, y: 30)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.brickImage.transform = CGAffineTransform.identity
            })
        })
    }
    
    func updateBrickImage(with weatherType: String) {
        switch weatherType {
        case "Rain", "Drizzle", "moderate rain", "light rain":
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
    
    @objc func hideKeyboard() {
        searchTextField.isHidden = true
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.isHidden = true
        searchTextField.resignFirstResponder()
        if let city = textField.text {
            updateWeatherData(for: city)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Whoops!", message: "This app requires an internet connection!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"),
                                      style: .default, handler: {_ in
            NSLog("The \"OK \" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
        brickImage.image = UIImage(named: "image_no_internet")
        temperatureLabel.text = ""
        typeOfWeatherLabel.text = ""
        locationLabel.text = ""
    }
}
