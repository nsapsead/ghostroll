import SwiftUI

struct JournalView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Training Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                Text("Your training sessions will appear here")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    JournalView()
}
