//
//  FavoritesManager.swift
//  MovieNight
//
//  Created by Drew Butler on 11/30/25.
//


import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    // accessible anywhere
    static let shared = FavoritesManager()
    
    // The list of favorite movies that Views will watch
    @Published var favorites: [TrendingItem] = []
    
    private let key = "SavedFavorites"
    
    init() {
        load()
    }
    
    // Check if a movie is already favorite
    func contains(_ movie: TrendingItem) -> Bool {
        favorites.contains { $0.id == movie.id }
    }
    
    // Add to favorites
        func add(_ movie: TrendingItem) {
            if !contains(movie) {
                // Create a clean copy of the movie without the leading slash
                var cleanPath = movie.poster_path
                if let path = cleanPath, path.hasPrefix("/") {
                    cleanPath = String(path.dropFirst())
                }
                
                let cleanMovie = TrendingItem(
                    adult: movie.adult,
                    id: movie.id,
                    poster_path: cleanPath, // Saved WITHOUT slash
                    title: movie.title,
                    vote_average: movie.vote_average
                )
                
                favorites.append(cleanMovie)
                save()
            }
        }
    
    // Remove from favorites
    func remove(_ movie: TrendingItem) {
        favorites.removeAll { $0.id == movie.id }
        save()
    }
    
    // Toggle (Add if missing, Remove if present)
    func toggle(_ movie: TrendingItem) {
        if contains(movie) {
            remove(movie)
        } else {
            add(movie)
        }
    }
    
    // Save to UserDefaults
    private func save() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Load from UserDefaults
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TrendingItem].self, from: data) {
            favorites = decoded
        }
    }
}
