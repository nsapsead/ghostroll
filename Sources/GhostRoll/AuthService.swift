import Foundation
import Firebase
import FirebaseAuth

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    self?.currentUser = User(
                        id: user.uid,
                        email: user.email ?? "",
                        displayName: user.displayName,
                        createdAt: user.metadata.creationDate ?? Date(),
                        lastLoginAt: user.metadata.lastSignInDate ?? Date()
                    )
                    self?.isAuthenticated = true
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print("User signed in: \(result.user.uid)")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign in error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update display name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
            
            print("User created: \(result.user.uid)")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign up error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out")
        } catch {
            errorMessage = error.localizedDescription
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("Password reset email sent")
        } catch {
            errorMessage = error.localizedDescription
            print("Password reset error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: String
    let email: String
    let displayName: String?
    let createdAt: Date
    let lastLoginAt: Date
}
