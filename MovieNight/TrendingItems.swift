//
//  TrendingItems.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import Foundation

struct TrendingItem: Identifiable, Codable {
    let adult: Bool?
    let id: Int
    let poster_path: String?
    let title: String?
    let vote_average: Double
}


extension TrendingItem {
    var posterURL: URL? {
        guard let p = poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w342\(p)")
    }
}
