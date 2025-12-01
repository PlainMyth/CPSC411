//
//  TrendingCard.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import Foundation
import SwiftUI

struct TrendingCard: View {
    let trendingItem: TrendingItem
    @ObservedObject var favorites = FavoritesManager.shared
    
    // Tracks attempts so we can force a reload if the download gets cancelled
    @State private var reloadID = UUID()
    @State private var attemptCount = 0

    // Compose a larger image for the horizontal carousel
    private var posterURL: URL? {
        guard let path = trendingItem.poster_path else { return nil }
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return URL(string: "https://image.tmdb.org/t/p/w500/\(cleanPath)")
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let url = posterURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle().opacity(0.08)
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill() // Ensures image fills the flexible frame
                    case .failure(let error):
                        ZStack {
                            Rectangle().opacity(0.08)
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.gray)
                                Text("Retry")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .onTapGesture {
                            attemptCount = 0
                            reloadID = UUID()
                        }
                        .onAppear {
                            if attemptCount < 3 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    attemptCount += 1
                                    reloadID = UUID()
                                }
                            }
                        }
                    @unknown default:
                        Color.clear
                    }
                }
                .id(reloadID)
            } else {
                ZStack {
                    Rectangle().opacity(0.08)
                    Image(systemName: "film")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
            }

            // overlay info bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(trendingItem.title ?? "Untitled")
                        .font(.headline)
                        .lineLimit(1)
                        .shadow(radius: 2)
                    Spacer()
                    Image(systemName: favorites.contains(trendingItem) ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                        .contentTransition(.symbolEffect(.replace))
                }
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", trendingItem.vote_average))
                        .font(.subheadline)
                    Spacer()
                }
            }
            .padding(10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding(8)
        }
        // CHANGED: got rid of fixed frame, added Aspect Ratio ---
        .aspectRatio(0.7, contentMode: .fit)
        .frame(maxWidth: .infinity) // allows it to fill the grid cell
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .onAppear {
            if attemptCount >= 3 {
                attemptCount = 0
                reloadID = UUID()
            }
        }
    }
}

struct SearchResultCard: View {
    let item: TrendingItem
    // Provide the poster URL builder so this stays decoupled from the ViewModel's static func
    let posterBuilder: (String?, String) -> URL?
    
    // NEW: Retry logic state
    @State private var reloadID = UUID()
    @State private var attemptCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // We use w342 here because if the column grows (on a pro max), w185 might be too blurry
            AsyncImage(url: posterBuilder(item.poster_path, "w342")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle().opacity(0.08)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Rectangle().opacity(0.08)
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onTapGesture {
                        attemptCount = 0
                        reloadID = UUID()
                    }
                    .onAppear {
                        // Auto-retry cancelled images (common in search scrolling)
                        // weird async fix for favoriting image errors
                        if attemptCount < 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                attemptCount += 1
                                reloadID = UUID()
                            }
                        }
                    }
                @unknown default:
                    Color.clear
                }
            }
            .id(reloadID)
            // --- RESPONSIVE FIX ---
            .aspectRatio(2/3, contentMode: .fit) // Standard movie poster ratio (1:1.5)
            .frame(maxWidth: .infinity)          // Fills the entire grid column
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(item.title ?? "Untitled")
                .font(.subheadline)
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text(String(format: "%.1f", item.vote_average))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TrendingCard(trendingItem: TrendingItem(
            adult: false,
            id: 1,
            poster_path: "/wuMc08IPKEatf9rnMNXvIDxqP4W.jpg", // A real Harry Potter path example
            title: "Harry Potter and the Philosopher's Stone",
            vote_average: 7.9
        ))
    }
}
