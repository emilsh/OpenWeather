//
//  OpenWeatherMapService.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import Foundation

class OpenWeatherMapService {
  
  private static let apiKey = "846df1eb261c4eeb019c2795d829e842"
  private static let host = "api.openweathermap.org"
  private static let units = "metric"
  private static let numberOfDays = "7"
  private static let language = "ru"
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd:HH"
    return formatter
  }()
  
  static func currentWeatherData(for city: String, completion: @escaping (OpenWeatherMapData?, Error?) -> ()) {
    var urlBuilder = URLComponents()
    urlBuilder.scheme = "https"
    urlBuilder.host = host
    urlBuilder.path = "/data/2.5/weather"
    urlBuilder.queryItems = [
      URLQueryItem(name: "appid", value: apiKey),
      URLQueryItem(name: "q", value: city),
      URLQueryItem(name: "units", value: units),
      URLQueryItem(name: "lang", value: language)
    ]
    
    guard let url = urlBuilder.url else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200..<300).contains(statusCode),
            let data = data else {
        completion(nil, error)
        return
      }
      
      do {
        let openWeatherMapData: OpenWeatherMapData = try JSONDecoder().decode(OpenWeatherMapData.self, from: data)
        completion(openWeatherMapData, nil)
      } catch {
        fatalError("Unable to decode!")
      }
    }.resume()
  }
  
  static func forecastWeatherData(for city: String, completion: @escaping (ForecastOpenWeatherMapData?, Error?) -> ()) {
    var urlBuilder = URLComponents()
    urlBuilder.scheme = "https"
    urlBuilder.host = host
    urlBuilder.path = "/data/2.5/forecast/daily"
    urlBuilder.queryItems = [
      URLQueryItem(name: "appid", value: apiKey),
      URLQueryItem(name: "q", value: city),
      URLQueryItem(name: "units", value: units),
      URLQueryItem(name: "lang", value: language),
      URLQueryItem(name: "cnt", value: numberOfDays)
    ]
    
    guard let url = urlBuilder.url else { return }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200..<300).contains(statusCode),
            let data = data else {
        completion(nil, error)
        return
      }
      
      do {
        let forecastWeatherMapData: ForecastOpenWeatherMapData = try JSONDecoder().decode(ForecastOpenWeatherMapData.self, from: data)
        completion(forecastWeatherMapData, nil)
      } catch {
        fatalError("Unable to decode!")
      }
    }.resume()
  }
  
  static func getIconForWeather(with iconName: String, completion: @escaping (Data?, Error?) -> ()) {
    
    guard let imageUrl = prepareUrlForIcon(iconName) else { return }
    
    URLSession.shared.downloadTask(with: imageUrl) { url, response, error in
      guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode,
            (200..<300).contains(statusCode),
            let url = url else {
        completion(nil, error)
        return
      }
      do {
        let data = try Data(contentsOf: url)
        completion(data, nil)
      } catch {
        fatalError("Cannot get data from url")
      }
    }.resume()
  }
  
  private static func prepareUrlForIcon(_ name: String) -> URL? {
    URL(string: "https://openweathermap.org/img/wn/\(name)@2x.png")
  }
}
