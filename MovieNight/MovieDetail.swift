//
//  MovieDetail.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import Foundation

struct Genre: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct MovieDetail: Decodable {
    let id: Int
    let title: String?
    let overview: String?
    let genres: [Genre]
    let poster_path: String?
    let vote_average: Double?
    let release_date: String?
    let runtime: Int?
    let vote_count: Int?
}

