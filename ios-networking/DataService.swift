//
//  DataService.swift
//  ios-networking
//
//  Created by Akshay Gajarlawar on 09/05/21.
//

import Foundation

enum CustomError: Error {
    case noData, badURL
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
    
    func url(withPath path: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = path
        return components.url
    }
    
    func authorizationString() -> String {
        //GitHub has discontinued password authentication to the API starting on November 13, 2020
        let authString = "" //Username and pwd
        var authStringBase64 = ""
        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }
        return authStringBase64
    }
    
    func fetchGists(completion:@escaping (Result<[Gist], Error>) -> Void) {
        
        guard let validURL = url(withPath: "/gists/public") else {
            completion(.failure(CustomError.badURL))
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
                completion(.failure(CustomError.noData))
                return
            }
            
            do {
                //To Get whole data as Json (Array/Dict)
                //let json = try JSONSerialization.jsonObject(with: validData, options: [])

                //Use of Codable model
                let gists = try JSONDecoder().decode([Gist].self, from:validData)
                
                completion(.success(gists))
            } catch let decodingError {
                completion(.failure(decodingError))
            }
            
        }.resume()
    }
    
    func createNewGist(completion:@escaping (Result<Any, Error>) -> Void) {
 
        guard let validURL = url(withPath: "/gists") else {
            completion(.failure(CustomError.badURL))
            return
        }
        
        var request = URLRequest.init(url: validURL)
        request.httpMethod = "POST"
        request.setValue("Basic \(authorizationString())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let newGist = Gist.init(id: nil, isPublic: true, description: "A new gist", files: ["sample.txt": File.init(content: "Hello World!")])
        
        do {
            let data = try JSONEncoder().encode(newGist)
            request.httpBody = data
        } catch let encodingError {
            completion(.failure(encodingError))
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status: \(httpResponse.statusCode)")
            }
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            guard let validData = data else {
                completion(.failure(CustomError.noData))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            } catch let serializationError {
                completion(.failure(serializationError))
            }
            
        }.resume()
        
    }
    
    func starUnstartGist(id:String, star: Bool, completion:@escaping (Bool)->Void) {
        guard let validURL =  url(withPath: "/gists/\(id)/star") else {
            completion(false)
            return
        }
        
        var request = URLRequest.init(url: validURL)
        request.httpMethod = star ? "PUT" : "DELETE"
        request.setValue("0", forHTTPHeaderField: "Content-Length")
        request.setValue("Basic \(authorizationString())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                print("API Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 204 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
