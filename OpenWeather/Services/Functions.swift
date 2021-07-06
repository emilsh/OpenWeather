//
//  Functions.swift
//  OpenWeather
//
//  Created by Emil Shafigin on 5/7/21.
//

import Foundation

func storeLastResultInUserDefaults(_ result: OpenWeatherMapData) {
  let city = result.name
  let temp = result.main.temp
  let description = result.weather[0].description
  let emojiString = result.weather[0].main
  let icon = result.weather[0].icon
  
  let defaults = UserDefaults.standard
  
  defaults.set(temp, forKey: "LastTemperature")
  defaults.set(city, forKey: "LastCity")
  defaults.set(description, forKey: "LastDescription")
  defaults.set(emojiString, forKey: "LastEmoji")
  defaults.set(icon, forKey: "LastIcon")
}

func getLastResultFromUserDefaults() -> OpenWeatherMapData? {
  let defaults = UserDefaults.standard
  
  let city = defaults.value(forKey: "LastCity") as? String
  let temp = defaults.value(forKey: "LastTemperature") as? Double
  let description = defaults.value(forKey: "LastDescription") as? String
  let emojiString = defaults.value(forKey: "LastEmoji") as? String
  let iconString = defaults.value(forKey: "LastIcon") as? String
  
  guard let city = city,
        let temp = temp,
        let description = description,
        let emojiString = emojiString,
        let icon = iconString else {
    return nil
  }
  
  let result = OpenWeatherMapData(name: city, weather: [OpenWeatherMapData.Weather(main: emojiString, description: description, icon: icon)], main: OpenWeatherMapData.Main(temp: temp))
  
  return result
}

func getLastCity() -> String? {
  UserDefaults.standard.value(forKey: "LastCity") as? String
}

func getRecommendations(for temp: Int) -> String {
  switch temp {
  case  -20..<0:
    return "Температура меньше 0 градусов"
  case 0...15:
    return "Температура от 0 до 15 градусов"
  case 16...40:
    return "Температура выше 15 градусов"
  default:
    return "Аномальная температура"
  }
}
