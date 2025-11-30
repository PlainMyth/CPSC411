//
//  ContentView.swift
//  MovieNight
//
//  Created by Sebastian C on 10/29/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MovieNightViewModel()

    // SEARCH STATE
    @State private var query = ""
    @State private var searchTask: Task<Void, Never>? = nil

    // Grid for search results
    private let gridCols = [
        GridItem(.fixed(120), spacing: 12),
        GridItem(.fixed(120), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // BACKGROUND
                LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(edges: .bottom)

                VStack(alignment: .leading, spacing: 12) {

                    if !query.isEmpty {
                        // SEARCH MODE
                        if viewModel.isSearching {
                            HStack { ProgressView(); Text("Searching…").foregroundStyle(.white) }
                                .padding(.horizontal)
                        }

                        ScrollView {
                            LazyVGrid(columns: gridCols, spacing: 14) {
                                ForEach(viewModel.searchResults) { item in
                                    NavigationLink(destination: MovieDetailView(movieId: item.id)) {
                                        SearchResultCard(item: item, posterBuilder: viewModel.posterURL)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 6)
                        }

                    } else {
                        // TRENDING MODE
                        if viewModel.trending.isEmpty {
                            HStack {
                                ProgressView()
                                Text("Loading…").foregroundStyle(.white)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.trending) { item in
                                        NavigationLink(destination: MovieDetailView(movieId: item.id)) {
                                            TrendingCard(trendingItem: item)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 280)
                        }
                    }
                }
                .padding(.top)
                .foregroundStyle(.white)
            }
            .navigationTitle("Movie Night")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .searchable(text: $query,
                       placement: .navigationBarDrawer(displayMode: .always),
                       prompt: "Search movies")
            .toolbarBackground(.black.opacity(0.9), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .task { await viewModel.loadTrending() }
        .onChange(of: query) { _, newValue in
            searchTask?.cancel()
            searchTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                await viewModel.searchMovies(query: newValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
