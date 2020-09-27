//
//  WeatherManager.swift
//  Clima
//
//  Created by Utsav Tulsyan on 27/09/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager,_ weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=7c3ad710958d7ba4a2b4c1177d68b427&units=metric"
    
    var delegate: WeatherManagerDelegate? = nil
    
    func fetchWeather(city: String){
        let urlString = "\(weatherUrl)&q=\(city)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double){
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            task.resume()
            
        }
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?){
        if let error = error{
            delegate?.didFailWithError(error)
            return
        }
        
        if let data = data {
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: data)
                let temp = decodedData.main.temp
                let id = decodedData.weather[0].id
                let name = decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                
                delegate?.didUpdateWeather(self, weather)
            } catch  {
                delegate?.didFailWithError(error)
            }
            
        }
    }
    
    
}
