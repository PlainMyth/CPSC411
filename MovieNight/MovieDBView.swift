import Foundation
import SwiftUI

@MainActor
class MovieNightViewModel: ObservableObject {
    @Published var trending: [TrendingItem] = []
    @Published var searchResults: [TrendingItem] = []
    @Published var isSearching = false
    
    // NEW: Holds the result of the random picker
    @Published var randomMovie: TrendingItem?

    // KEEP YOUR TOKEN HERE
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
                return
            }
            let decoded = try JSONDecoder().decode(TrendingResults.self, from: data)
            trending = decoded.results
        } catch {
            print("Trending error:", error)
        }
    }

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
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(TrendingResults.self, from: data)
            searchResults = decoded.results
        } catch {
            searchResults = []
        }
        isSearching = false
    }

    // NEW: Random Movie Picker Logic
    func pickRandomMovie(genreId: Int, minYear: Int, maxYear: Int, minScore: Double, maxScore: Double) async -> Bool {
            // 1. CLEAR OLD DATA IMMEDIATELY
            // This ensures we never show a "stale" movie.
            randomMovie = nil
            
            let randomPage = Int.random(in: 1...20)
            
            let urlString = "https://api.themoviedb.org/3/discover/movie?with_genres=\(genreId)&primary_release_date.gte=\(minYear)-01-01&primary_release_date.lte=\(maxYear)-12-31&vote_average.gte=\(minScore)&vote_average.lte=\(maxScore)&vote_count.gte=100&include_adult=false&sort_by=popularity.desc&page=\(randomPage)"
            
            guard let url = URL(string: urlString) else { return false }
            
            // 2. DISABLE CACHING
            // Forces a fresh network call every time
            var request = makeRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode(TrendingResults.self, from: data)
                
                if let randomPick = decoded.results.randomElement() {
                    randomMovie = randomPick
                    return true // Success!
                }
                return false
            } catch {
                print("Random pick error:", error)
                return false // Failure
            }
        }

    func posterURL(from path: String?, size: String = "w185") -> URL? {
        guard let path = path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(path)")
    }
    
    func fetchMovieDetails(movieId: Int) async -> MovieDetail? {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)") else { return nil }
        let request = makeRequest(url: url)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(MovieDetail.self, from: data)
            return decoded
        } catch {
            return nil
        }
    }
}
