//
//  ViewController.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
  
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var commentLabel: UILabel!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var iconImageView: UIImageView!
  
  var locationManager = CLLocationManager()
  var location: CLLocation!
  var isFirstRunning: Bool = true

  override func viewDidLoad() {
    super.viewDidLoad()
    cityTextField.delegate = self
    if let weatherData = getLastResultFromUserDefaults() {
      updateUI(with: weatherData)
    }
    startLocationManager()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if isFirstRunning {
      checkLocationRestrictions()
      isFirstRunning.toggle()
    }
  }
  
  func checkLocationRestrictions() {
    let authStatus = locationManager.authorizationStatus
    if authStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
      return
    }
    if authStatus == .denied || authStatus == .restricted {
      let message = "У приложения нет доступа к Вашей геопозиции. Пожалуйста, разрешите доступ или введите интересующий Вас город."
      showAlert(with: message)
      return
    }
  }
  
  func startLocationManager() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
    }
  }
    
  func stopLocationManager() {
    locationManager.stopUpdatingLocation()
    locationManager.delegate = nil
    }
  
  func updateUI(with weatherData: OpenWeatherMapData) {
    let temp = Int(weatherData.main.temp)
    let recommendations = getRecommendations(for: temp)
    let comment = "\(weatherData.weather[0].description.capitalized)\n\(recommendations)"
    let iconName = weatherData.weather[0].icon
    
    cityLabel.text = weatherData.name
    temperatureLabel.text = "\(temp)℃"
    commentLabel.text = comment
    
    OpenWeatherMapService.getIconForWeather(with: iconName) { [weak self] data, error in
      guard let self = self, error == nil, let data = data else { return }
      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.iconImageView.image = image
      }
    }
  }
  
  func fetchWeather(for city: String) {
    OpenWeatherMapService.currentWeatherData(for: city) { [weak self] result, error in
      guard let self = self,
            let result = result else {
        DispatchQueue.main.async {
          self?.showAlert(with: "Не удается найти указанный город")
        }
        return
      }
      storeLastResultInUserDefaults(result)
      
      DispatchQueue.main.async {
        self.updateUI(with: result)
      }
    }
  }
  
  func showAlert(with message: String) {
    let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
  
  fileprivate func getCity(from location: CLLocation) {
    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
      guard error == nil, let places = placemarks, !places.isEmpty else { return }
      let city = places.last!.locality ?? ""
      self.fetchWeather(for: city)
    }
  }
}

extension ViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
      
    if newLocation.timestamp.timeIntervalSinceNow < -5 {
      return
    }
    if newLocation.horizontalAccuracy < 0 {
      return
    }
    
    if location == nil || location!.horizontalAccuracy >= newLocation.horizontalAccuracy {
      location = newLocation
      
      if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
        stopLocationManager()
        getCity(from: newLocation)
      }
    }
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.hasText {
      fetchWeather(for: textField.text!)
    } else {
      startLocationManager()
    }
    textField.resignFirstResponder()
    return true
  }
}
