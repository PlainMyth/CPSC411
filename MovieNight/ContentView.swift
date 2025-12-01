import SwiftUI

struct ContentView: View {
    // We use an Enum to track which tab is selected
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Tab 2: Search
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            // Tab 3: Random Movie Chooser
            RandomMovieView()
                            .tabItem { Label("Random", systemImage: "questionmark.circle.fill") }
                            .tag(2)
                
            // Tab 4: Favorites
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(3)
        }
        .preferredColorScheme(.dark) // Keeps the dark theme everywhere
        .tint(.white) // Makes the selected tab icon white
        
    }
}

#Preview {
    ContentView()
}
