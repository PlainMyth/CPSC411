//
//  RandomMovieView.swift
//  MovieNight
//
//  Created by Drew Butler on 11/30/25.
//


import SwiftUI

struct RandomMovieView: View {
    @StateObject var viewModel = MovieNightViewModel()
    @State private var showResult = false
    @State private var showError = false
    
    // FILTERS
    @State private var scoreRange: ClosedRange<Double> = 5.0...10.0
    @State private var yearRange: ClosedRange<Double> = 1990...2025
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]
    
    // Manual list of popular TMDB Genres
    let genres = [
        (id: 28, name: "Action", icon: "flame.fill", color: Color.red),
        (id: 35, name: "Comedy", icon: "face.smiling.inverse", color: Color.yellow),
        (id: 27, name: "Horror", icon: "eye.trianglebadge.exclamationmark.fill", color: Color.purple),
        (id: 878, name: "Sci-Fi", icon: "atom", color: Color.cyan),
        (id: 10749, name: "Romance", icon: "heart.fill", color: Color.pink),
        (id: 16, name: "Animation", icon: "paintbrush.fill", color: Color.orange),
        (id: 53, name: "Thriller", icon: "figure.run", color: Color.blue),
        (id: 18, name: "Drama", icon: "theatermasks.fill", color: Color.green)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(colors: [.black, .gray], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // --- FILTER CONTROLS ---
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Filters")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            // Score Range Slider
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Score Range")
                                        .font(.subheadline).foregroundStyle(.gray)
                                    Spacer()
                                    // Displays "1.0 - 4.5"
                                    Text("\(String(format: "%.1f", scoreRange.lowerBound)) - \(String(format: "%.1f", scoreRange.upperBound))")
                                        .font(.subheadline).bold().foregroundStyle(.yellow)
                                }
                                
                                // Reuse the helper we made for years!
                                RangeSliderView(range: $scoreRange, bounds: 0.0...10.0)
                            }
                            
                            Divider().background(.gray)
                            
                            // Year Slider
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text("Release Year")
                                        .font(.subheadline).foregroundStyle(.gray)
                                    Spacer()
                                    Text("\(Int(yearRange.lowerBound)) - \(Int(yearRange.upperBound))")
                                        .font(.subheadline).bold().foregroundStyle(.white)
                                }
                                // Using standard slider for simplicity (adjusts end year)
                                // or use the RangeSlider helper below
                                RangeSliderView(range: $yearRange, bounds: 1970...2025)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                        
                        // --- GENRE GRID ---
                        Text("Tap a Genre to Pick")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(genres, id: \.id) { genre in
                                Button {
                                    Task {
                                        let success = await viewModel.pickRandomMovie(
                                            genreId: genre.id,
                                            minYear: Int(yearRange.lowerBound),
                                            maxYear: Int(yearRange.upperBound),
                                            minScore: scoreRange.lowerBound,
                                            maxScore: scoreRange.upperBound
                                        )
                                        
                                        if success {
                                            showResult = true
                                        } else {
                                            // NEW: If it failed, show the error alert
                                            showError = true
                                        }
                                    }
                                } label: {
                                    VStack(spacing: 12) {
                                        Image(systemName: genre.icon)
                                            .font(.system(size: 40))
                                            .foregroundStyle(genre.color)
                                        Text(genre.name)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 120)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Random Picker")
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showResult) {
                if let movie = viewModel.randomMovie {
                    NavigationStack {
                        MovieDetailView(movieId: movie.id)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") { showResult = false }
                                }
                            }
                    }
                } else {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        ProgressView("Rolling the dice...")
                            .foregroundStyle(.white)
                    }
                    .presentationDetents([.medium])
                }
            }
            .alert("No Movies Found", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We couldn't find any movies with those specific filters. Try widening your year range or score.")
            }
        }
    }
}

// Simple Helper for the two-handle slider
struct RangeSliderView: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width(for: range, in: bounds, totalWidth: geometry.size.width), height: 4)
                    .offset(x: position(for: range.lowerBound, in: bounds, totalWidth: geometry.size.width))
                
                // Lower Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: position(for: range.lowerBound, in: bounds, totalWidth: geometry.size.width) - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location.x
                                let percentage = location / geometry.size.width
                                let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(percentage)
                                if newValue < range.upperBound {
                                    range = max(bounds.lowerBound, newValue)...range.upperBound
                                }
                            }
                    )
                
                // Upper Handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .offset(x: position(for: range.upperBound, in: bounds, totalWidth: geometry.size.width) - 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location.x
                                let percentage = location / geometry.size.width
                                let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(percentage)
                                if newValue > range.lowerBound {
                                    range = range.lowerBound...min(bounds.upperBound, newValue)
                                }
                            }
                    )
            }
            .frame(height: 30) // Give it touch area height
        }
        .frame(height: 30)
    }
    
    private func position(for value: Double, in bounds: ClosedRange<Double>, totalWidth: CGFloat) -> CGFloat {
        let percentage = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return totalWidth * CGFloat(percentage)
    }
    
    private func width(for range: ClosedRange<Double>, in bounds: ClosedRange<Double>, totalWidth: CGFloat) -> CGFloat {
        let lower = position(for: range.lowerBound, in: bounds, totalWidth: totalWidth)
        let upper = position(for: range.upperBound, in: bounds, totalWidth: totalWidth)
        return upper - lower
    }
}

#Preview {
    RandomMovieView()
}
