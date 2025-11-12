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

    // Compose a larger image for the horizontal carousel
    private var posterURL: URL? {
        guard let path = trendingItem.poster_path else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
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
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Rectangle().opacity(0.08)
                            Image(systemName: "film")
                                .imageScale(.large)
                                .foregroundStyle(.secondary)
                        }
                    @unknown default:
                        Color.clear
                    }
                }
            } else {
                ZStack {
                    Rectangle().opacity(0.08)
                    Image(systemName: "film")
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                }
            }

            // Overlay info bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(trendingItem.title ?? "Untitled")
                        .font(.headline)
                        .lineLimit(1)
                        .shadow(radius: 2)
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
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
        .frame(width: 180, height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
    }
}

struct SearchResultCard: View {
    let item: TrendingItem
    /// Provide the poster URL builder so this stays decoupled from the ViewModel's static func
    let posterBuilder: (String?, String) -> URL?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: posterBuilder(item.poster_path, "w185")) { phase in
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
                        Image(systemName: "film")
                            .imageScale(.large)
                            .foregroundStyle(.secondary)
                    }
                @unknown default:
                    Color.clear
                }
            }
            .frame(width: 120, height: 180)
            .clipped()
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
        .frame(width: 120, alignment: .leading)
    }
}
