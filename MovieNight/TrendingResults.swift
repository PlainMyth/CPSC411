//
//  TrendingResults.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import Foundation

struct TrendingResults: Decodable {
    let page: Int?
    let results: [TrendingItem]
    let total_pages: Int?
    let total_results: Int?
}
