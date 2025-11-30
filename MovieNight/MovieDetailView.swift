//
//  MovieDetailView.swift
//  MovieNight
//
//  Created by Sebastian C on 11/10/25.
//

import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    @StateObject private var viewModel = MovieNightViewModel()
    @State private var movieDetail: MovieDetail?
    @State private var isLoading = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // BACKGROUND
            LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                    Text("Loading...")
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                }
            } else if let detail = movieDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Movie Poster
                        if let posterPath = detail.poster_path,
                           let url = viewModel.posterURL(from: posterPath, size: "w500") {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 500)
                                        ProgressView()
                                    }
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 500)
                                case .failure:
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 300)
                                        Image(systemName: "film")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                    }
                                @unknown default:
                                    Color.clear
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Title and Rating
                            VStack(alignment: .leading, spacing: 8) {
                                Text(detail.title ?? "Untitled")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                
                                if let voteAverage = detail.vote_average {
                                    HStack(spacing: 6) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", voteAverage))
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Genres
                            if !detail.genres.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Genres")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    
                                    GenreFlowView(genres: detail.genres)
                                }
                                .padding(.horizontal)
                            }
                            
                            // Synopsis
                            if let overview = detail.overview, !overview.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Synopsis")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    
                                    Text(overview)
                                        .font(.body)
                                        .foregroundStyle(.white.opacity(0.9))
                                        .lineSpacing(4)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                    Text("Failed to load movie details")
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            movieDetail = await viewModel.fetchMovieDetails(movieId: movieId)
            isLoading = false
        }
    }
}

// Helper view for horizontal flow layout of genres using a simpler approach
struct GenreFlowView: View {
    let genres: [Genre]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(chunkedGenres(), id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row) { genre in
                        Text(genre.name)
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.7), in: Capsule())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func chunkedGenres() -> [[Genre]] {
        var rows: [[Genre]] = []
        var currentRow: [Genre] = []
        var currentWidth: CGFloat = 0
        let screenWidth = UIScreen.main.bounds.width - 64 // Account for padding
        
        for genre in genres {
            let estimatedWidth = CGFloat(genre.name.count) * 8 + 32 // Rough estimate based on text length
            
            if currentWidth + estimatedWidth > screenWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [genre]
                currentWidth = estimatedWidth
            } else {
                currentRow.append(genre)
                currentWidth += estimatedWidth + 8
            }
        }
        
        if !currentRow.isEmpty {
            rows.append(currentRow)
        }
        
        return rows
    }
}

#Preview {
    NavigationStack {
        MovieDetailView(movieId: 550)
    }
}

