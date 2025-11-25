import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                if let user = authService.currentUser {
                    VStack(spacing: 15) {
                        Text("Welcome, \(user.displayName ?? user.email)")
                            .font(.title2)
                        
                        Text("Email: \(user.email)")
                            .foregroundColor(.secondary)
                        
                        Text("Member since: \(user.createdAt, style: .date)")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer()
                
                Button("Sign Out") {
                    authService.signOut()
                }
                .foregroundColor(.red)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
}
