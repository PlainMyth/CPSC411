//
//  SearchView.swift
//  MovieNight
//
//  Created by Drew Butler on 11/30/25.
//


import SwiftUI

struct SearchView: View {
    @StateObject var viewModel = MovieNightViewModel()
    @State private var query = ""
    @State private var searchTask: Task<Void, Never>? = nil

    let gridCols = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    if query.isEmpty {
                        ContentUnavailableView("Search Movies", systemImage: "magnifyingglass", description: Text("Find your favorite films"))
                            .foregroundStyle(.white)
                    } else if viewModel.isSearching {
                        ProgressView()
                            .tint(.white)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: gridCols, spacing: 16) {
                                ForEach(viewModel.searchResults) { item in
                                    NavigationLink(destination: MovieDetailView(movieId: item.id)) {
                                        SearchResultCard(item: item, posterBuilder: viewModel.posterURL)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .preferredColorScheme(.dark)
            .searchable(text: $query, prompt: "Search movies...")
            .onChange(of: query) { _, newValue in
                searchTask?.cancel()
                searchTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    await viewModel.searchMovies(query: newValue)
                }
            }
        }
    }
}

#Preview {
    SearchView()
}
