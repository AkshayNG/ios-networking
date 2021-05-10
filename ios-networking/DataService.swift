//
//  DataService.swift
//  ios-networking
//
//  Created by Akshay Gajarlawar on 09/05/21.
//

import Foundation

enum DataError: Error {
    case noData
}

class DataService {
    static let shared = DataService()
    
    fileprivate let baseURLString = "https://api.github.com"
    
    func testURLs() {
        //Way 1
        var baseURL = URL.init(string: baseURLString)
        baseURL?.appendPathComponent("/somePath")
        print(baseURL!)
        
        //Way 2
        let composedURL = URL.init(string: "/somePath", relativeTo: baseURL)
        print(composedURL?.absoluteString ?? "No ewlative URL")
        
        //Way 3: new & improved way
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/somePath"
        print(componentURL.url!)
    }
    
    func fetchGists(completion:@escaping (Result<[Gist], Error>) -> Void) {
        
        var componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/gists/public"
        
        guard let validURL = componentURL.url else {
            print("Invalid URL!")
            return
        }
        
        print("API Request: \(validURL)")
        
        URLSession.shared.dataTask(with: validURL) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status: \(httpResponse.statusCode)")
            }
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let validData = data else {
                completion(.failure(DataError.noData))
                return
            }
            
            do {
                //To Get whole data as Json (Array/Dict)
                //let json = try JSONSerialization.jsonObject(with: validData, options: [])

                //Use of Codable model
                let gists = try JSONDecoder().decode([Gist].self, from:validData)
                
                completion(.success(gists))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
        
    }
}
