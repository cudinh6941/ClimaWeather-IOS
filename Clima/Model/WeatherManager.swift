//
//  WeatherManager.swift
//  Clima
//
//  Created by pham kha dinh on 16/02/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather : WeatherModel)
    func didFailWithErorr(_ error: Error)
}

struct WeatherManager {
    let url = "https://api.openweathermap.org/data/2.5/weather?appid=f315a8450b1d0bb94c3a56a34b328ec0&units=metric"
    var delegate : WeatherManagerDelegate?
    func fetchWeather(cityName : String){
        let urlString = "\(url)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longtitude: CLLocationDegrees){
        let urlString = "\(url)&lat=\(latitude)&lon=\(longtitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString : String){
        // 1. create a URL
        if let url = URL(string: urlString){
            // 2. create a URL session
            let session = URLSession(configuration: .default)
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithErorr(error!)
                    return
                }
                if let safeData = data{
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self,weather: weather)
                    }
                }
                
            }            // 4. Start the task
            task.resume()
        }
    }
    func parseJSON(_ weatherData : Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        
        }catch{
            self.delegate?.didFailWithErorr(error)
            return nil
        }
    }
    
}
