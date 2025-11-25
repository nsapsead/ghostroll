import SwiftUI

struct GoalsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Training Goals")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Text("Your training goals will appear here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Goals")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    GoalsView()
}
