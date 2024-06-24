//
//  WeatherForecastService.swift
//  CloudCast
//
//  Created by Michael on 24/06/2024.
//

import Foundation

class WeatherForecastService {

  static func fetchForecast(
    latitude: Double,
    longitude: Double,
    completion: ((CurrentWeatherForecast) -> Void)? = nil
  ) {
    let parameters =
      "latitude=\(latitude)&longitude=\(longitude)&current_weather=true&timezone=auto&windspeed_unit=mph"
    let url = URL(string: "https://api.open-meteo.com/v1/forecast?\(parameters)")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      guard error == nil else {
        assertionFailure("error is \(error!.localizedDescription)")
        return
      }
      guard let httpResponse = response as? HTTPURLResponse else {
        assertionFailure("reponse in not valid")
        return
      }
      guard let data = data, httpResponse.statusCode == 200 else {
        assertionFailure("invalid respose status code \(httpResponse.statusCode)")
        return
      }
        //let weatherforcast = parse(data: data)
        let decoder = JSONDecoder()
        let response = try! decoder.decode(WeatherAPIResponse.self, from: data)
        DispatchQueue.main.async {
            completion?(response.currentWeather)
        }

    }
    task.resume()
  }

  private static func parse(data: Data) -> CurrentWeatherForecast {
    // transform the data we received into a dictionary [String: Any]
    let jsonDictionary =
      try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    let currentWeather = jsonDictionary["current_weather"] as! [String: Any]
    // wind speed
    let windSpeed = currentWeather["windspeed"] as! Double
    // wind direction
    let windDirection = currentWeather["winddirection"] as! Double
    // temperature
    let temperature = currentWeather["temperature"] as! Double
    // weather code
    let weatherCodeRaw = currentWeather["weathercode"] as! Int
    return CurrentWeatherForecast(
      windSpeed: windSpeed,
      windDirection: windDirection,
      temperature: temperature,
      weatherCodeRaw: weatherCodeRaw)
  }
}
