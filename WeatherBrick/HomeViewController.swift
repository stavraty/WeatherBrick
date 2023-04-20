//
//  Created by Volodymyr Andriienko on 11/3/21.
//  Copyright © 2021 VAndrJ. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

let reachability = try! Reachability()

class HomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private var infoButton: UIButton!
    @IBOutlet private var brickImage: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var typeOfWeatherLabel: UILabel!
    @IBOutlet private var locationLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var locationButton: UIButton!
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var searchTextField: UITextField!
    
    let networkManager = NetworkManager()
    var cityName: String = ""
    static let locationManager = CLLocationManager()
    
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        setupRefreshControl()
        setupLocationManager()
        setupGradientLayer()
        setupInfoButton()
        setupSearchButton()
        setupSearchTextField()
        setupReachabilityNotifier()
        setupRefreshControlInBrickImage()
        setupPanGesture()
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
    
    func setupRefreshControl() {
        scrollView.refreshControl = myRefreshControl
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = infoButton.bounds
        gradientLayer.colors = [UIColor(red: 1, green: 0.6, blue: 0.38, alpha: 1).cgColor, UIColor(red: 0.98, green: 0.31, blue: 0.11, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        infoButton.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupInfoButton() {
        let cornerRadius: CGFloat = 20.0
        infoButton.layer.cornerRadius = cornerRadius
        infoButton.clipsToBounds = true
        infoButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        infoButton.titleLabel?.font = UIFont(name: "SFProDisplay-Semibold", size: 22)
    }
    
    func setupSearchButton() {
        locationButton.setImage(locationImageView.image, for: .normal)
        searchButton.setImage(searchImageView.image, for: .normal)
        searchButton.addTarget(self, action: #selector(pushToSearchButton), for: .touchUpInside)
    }
    
    func setupSearchTextField() {
        searchTextField.isHidden = true
        searchTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        searchTextField.layer.shadowColor = UIColor.black.cgColor
        searchTextField.layer.shadowOpacity = 0.5
        searchTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchTextField.layer.shadowRadius = 2
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupReachabilityNotifier() {
        reachability.whenUnreachable = { _ in
            self.showAlertNoConnections()
            self.brickImage.image = UIImage(named: "image_no_internet")
            self.temperatureLabel.text = ""
            self.typeOfWeatherLabel.text = ""
            self.locationLabel.text = ""
        }
        if let _ = try? reachability.startNotifier() {
            
        } else {
            
        }
    }
    
    func setupRefreshControlInBrickImage() {
        brickImage.addSubview(myRefreshControl)
    }
    
    func setupPanGesture() {
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
                fetchData()
            }
        default:
            break
        }
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
    
    @objc func hideKeyboard() {
        searchTextField.isHidden = true
        view.endEditing(true)
    }
    
    func showAlertNoConnections() {
        let alert = UIAlertController(title: "Whoops!", message: "This app requires an internet connection!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default Action"),
                                      style: .default, handler: {_ in
            NSLog("The \"OK \" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(with error: Error?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func fetchData() {
        if let location = locationManager.location {
            networkManager.fetchWeatherData(location: location, city: nil) { result in
                switch result {
                case .success(let weatherData):
                    self.updateUI(with: weatherData)
                case .failure(let error):
                    self.showErrorAlert(with: error)
                }
            }
        }
    }
    
    func fetchDataForCity(_ city: String) {
        networkManager.fetchWeatherData(location: nil, city: city) { result in
            switch result {
            case .success(let weatherData):
                self.updateUI(with: weatherData)
            case .failure(let error):
                self.showErrorAlert(with: error)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.isHidden = true
        searchTextField.resignFirstResponder()
        if let city = textField.text {
            cityName = city
            fetchDataForCity(city)
        }
        textField.resignFirstResponder()
        return true
    }
    
    private func updateUI(with weatherData: WeatherData) {
        DispatchQueue.main.async {
            let weatherType = weatherData.weather.first?.description ?? ""
            self.typeOfWeatherLabel.text = weatherType
            let temperature = Int(weatherData.main.temp - 273.15)
            self.temperatureLabel.text = "\(temperature)°"
            let cityName = weatherData.name
            let countryCode = weatherData.sys.country
            let locationText = NSMutableAttributedString(string: "")
            locationText.append(NSAttributedString(string: " \(cityName), \(countryCode) "))
            self.locationLabel.attributedText = locationText
            self.updateBrickImage(with: weatherType)
            
            UIView.animate(withDuration: 0.1, animations: {
                self.brickImage.transform = CGAffineTransform(translationX: 0, y: 30)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.brickImage.transform = CGAffineTransform.identity
                })
            })
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        locationManager.stopUpdatingLocation()
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&appid=\(apiKey)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                self.showErrorAlert(with: error)
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                self.showErrorAlert(with: error)
            }
        }
        task.resume()
    }
}
