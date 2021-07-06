//
//  OpenWeatherMapData.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import Foundation

struct OpenWeatherMapData: Decodable {
  var name: String
  var weather: [Weather]
  var main: Main
  
  struct Weather: Decodable {
    var main: String
    var description: String
    var icon: String
  }
  
  struct Main: Decodable {
    var temp: Double
  }
}

struct ForecastOpenWeatherMapData: Decodable {
  var city: City
  var list: [List]
  
  struct City: Decodable {
    var name: String
  }
  
  struct List: Decodable {
    var dt: TimeInterval
    var weather: [Weather]
    var temp: Temp
  }
  
  struct Weather: Decodable {
    var description: String
    var icon: String
  }
  
  struct Temp: Decodable {
    var day: Double
    var night: Double
  }
}
