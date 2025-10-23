//
//  FilmResponse.swift
//  Movie_App
//
//  Created by Admin on 10/6/25.
//

import Foundation
//
//  FilmResponse.swift
//  Movie_App
//
//  Created by Admin on 10/6/25.
//

import Foundation
struct FilmResponse : Codable {
    let page: Int
    let results: [Film]
    let total_results: Int
    let total_pages: Int
    
   
}
