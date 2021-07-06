//
//  WeatherCell.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import UIKit

class WeatherCell: UITableViewCell {
  static let reuseIdentifer = String(describing: WeatherCell.self)
  
  @IBOutlet weak var dayOfWeekLabel: UILabel!
  @IBOutlet weak var dayTempLabel: UILabel!
  @IBOutlet weak var nightTempLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  
  lazy var formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.setLocalizedDateFormatFromTemplate("EEEE")
    return formatter
  }()
  
  func configure(for list: ForecastOpenWeatherMapData.List) {
    let dayTemp = Int(list.temp.day)
    let nightTemp = Int(list.temp.night)
    let icon = list.weather[0].icon
    
    dayOfWeekLabel.text = formatter.string(from: Date(timeIntervalSince1970: list.dt)).capitalized
    
    dayTempLabel.text = "\(dayTemp)"
    nightTempLabel.text = "\(nightTemp)"
    
    OpenWeatherMapService.getIconForWeather(with: icon) { [weak self] data, error in
      guard let self = self, error == nil, let data = data else { return }
      let image = UIImage(data: data)
      DispatchQueue.main.async {
        self.iconImageView.image = image
      }
    }
  }
}
