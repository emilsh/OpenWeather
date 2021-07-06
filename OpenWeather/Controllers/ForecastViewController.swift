//
//  ForecastViewController.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import UIKit

class ForecastViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  
  var forecastWeather: ForecastOpenWeatherMapData?
  var city: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTableView()
    if let city = getLastCity() {
      self.city = city
      fetchForecast(for: city)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if city != getLastCity() && getLastCity() != nil {
      city = getLastCity()!
      fetchForecast(for: city)
    }
  }
  
  func updateUI() {
    guard let forecastWeather = forecastWeather else { return }
    let city = forecastWeather.city.name
    let temp = Int(forecastWeather.list[0].temp.day)
    let icon = forecastWeather.list[0].weather[0].icon
    
    cityLabel.text = city
    temperatureLabel.text = "\(temp)℃"
    
    OpenWeatherMapService.getIconForWeather(with: icon) { [weak self] data, error in
      guard let self = self, error == nil, let data = data else { return }
      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.iconImageView.image = image
      }
    }
  }
  
  func fetchForecast(for city: String) {
    OpenWeatherMapService.forecastWeatherData(for: city) { [weak self] result, error in
      guard let self = self,
            let result = result else {
        return
      }
      self.forecastWeather = result
      DispatchQueue.main.async {
        self.updateUI()
        self.tableView.reloadData()
      }
    }
  }
}

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
  func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let list = forecastWeather?.list else {
      return 0
    }
    return list.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherCell.reuseIdentifer, for: indexPath) as? WeatherCell,
          let forecastWeather = forecastWeather else {
      return UITableViewCell()
    }
    let list = forecastWeather.list[indexPath.row]
    cell.configure(for: list)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }
}
