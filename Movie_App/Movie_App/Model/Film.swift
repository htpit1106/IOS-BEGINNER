//
//  Film.swift
//  Movie_App
//
//  Created by Admin on 10/6/25.
//

import Foundation

struct Film: Codable {

    
    private(set) var adult: Bool?
    private(set) var title: String?
    private(set) var id: Int
    private(set) var original_title: String?
    private(set) var original_language: String?
    private(set) var overview: String?
    private(set) var poster_path: String?
    private(set) var media_type: String?
    private(set) var vote_average : Double?
    private(set) var genre_ids:[Int]
    private(set) var popularity: Double?
    private(set) var release_date: String?
    private(set) var vote_count: Int?
    private(set) var backdrop_path: String?
    
    private(set) var favourited: Bool?
    mutating func setFavourited(_ value: Bool) {
        favourited = value
    }
    
    
}
