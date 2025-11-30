//
//  MovieDBView.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import Foundation
import SwiftUI

@MainActor
class MovieNightViewModel: ObservableObject {
    @Published var trending: [TrendingItem] = []
    @Published var searchResults: [TrendingItem] = []
    @Published var isSearching = false

   
    static let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwMzViZWMxOTZmYjBmMGY3Y2I3OGRhNDdmNTkxMTI3YSIsIm5iZiI6MTc2MTc4MjIwNC41NzUsInN1YiI6IjY5MDJhOWJjNmNlOGM4ZDI0NTFmOGI5YSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.H6s5OGL8smX39fwYilFCx0g6UI14QzlgO1Sn4lNzpYA"


    private func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(Self.bearerToken)", forHTTPHeaderField: "Authorization")
        return request
    }

   
    func loadTrending() async {
        guard let url = URL(string: "https://api.themoviedb.org/3/trending/movie/day") else { return }
        let request = makeRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                print("Trending bad status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                print(String(data: data, encoding: .utf8) ?? "")
                return
            }

            let decoded = try JSONDecoder().decode(TrendingResults.self, from: data)
            trending = decoded.results
        } catch {
            print("Trending fetch/decode error:", error)
        }
    }

    // Search
    func searchMovies(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        guard let q = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(q)&include_adult=false&language=en-US&page=1")
        else { return }

        let request = makeRequest(url: url)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                print("Search bad status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                print(String(data: data, encoding: .utf8) ?? "")
                searchResults = []
                isSearching = false
                return
            }

            let decoded = try JSONDecoder().decode(TrendingResults.self, from: data)
            searchResults = decoded.results
        } catch {
            print("Search error:", error)
            searchResults = []
        }

        isSearching = false
    }

    // Poster URL
    func posterURL(from path: String?, size: String = "w185") -> URL? {
        guard let path = path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }
    
    // Fetch movie details
    func fetchMovieDetails(movieId: Int) async -> MovieDetail? {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)") else { return nil }
        let request = makeRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                print("Movie details bad status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                print(String(data: data, encoding: .utf8) ?? "")
                return nil
            }
            
            let decoded = try JSONDecoder().decode(MovieDetail.self, from: data)
            return decoded
        } catch {
            print("Movie details fetch/decode error:", error)
            return nil
        }
    }
}
