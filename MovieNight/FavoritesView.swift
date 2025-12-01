//
//  FavoritesView.swift
//  MovieNight
//
//  Created by Drew Butler on 11/30/25.
//


import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favorites = FavoritesManager.shared
    
    // Flexible grid layout
    let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if favorites.favorites.isEmpty {
                    ContentUnavailableView("No Favorites", 
                        systemImage: "heart.slash", 
                        description: Text("Movies you like will appear here"))
                        .foregroundStyle(.white)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(favorites.favorites) { item in
                                NavigationLink(destination: MovieDetailView(movieId: item.id)) {
                                    TrendingCard(trendingItem: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    // We can wrap this in a NavigationStack so the title shows up in the preview
    NavigationStack {
        FavoritesView()
    }
}
