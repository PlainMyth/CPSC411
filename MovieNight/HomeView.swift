//
//  HomeView.swift
//  MovieNight
//
//  Created by Drew Butler on 11/30/25.
//


import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = MovieNightViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Trending Today")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal)

                        if viewModel.trending.isEmpty {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.trending) { item in
                                        NavigationLink(destination: MovieDetailView(movieId: item.id)) {
                                            TrendingCard(trendingItem: item)
                                                .frame(width: 180)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Movie Night")
            .task {
                await viewModel.loadTrending()
            }
        }
    }
}

#Preview {
    HomeView()
}
