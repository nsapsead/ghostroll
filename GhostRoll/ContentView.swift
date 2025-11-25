import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService())
}
