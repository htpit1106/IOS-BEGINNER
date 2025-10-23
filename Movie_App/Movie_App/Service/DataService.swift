//
//  DataService.swift
//  Movie_App
//
//  Created by Admin on 10/6/25.
//

import Foundation

class DataService {
    static let instance = DataService()
    
    func getFilmList (page: Int) async throws -> FilmResponse {
            
        

        let url = URL(string: "https://api.themoviedb.org/3/movie/popular")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "language", value: "en-US"),
          URLQueryItem(name: "page", value: "\(page)"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2YmFiMWZiZmM3MDAxODE1ODM4NmE0NDcwNjBhYzM4NSIsIm5iZiI6MTc1OTg5NjA2Mi4zNTAwMDAxLCJzdWIiOiI2OGU1ZTFmZTAwNDgyMTYxMTJhOTk0ZDUiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.C1qEcWvyRZrAY45QmWPATHGWpXYkbghFOo9wd9skB98"
        ]

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(FilmResponse.self, from: data)
        return decoded
    }
    
    
}
