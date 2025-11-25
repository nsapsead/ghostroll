import SwiftUI

struct AuthenticationView: View {
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "figure.martial.arts")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("GhostRoll")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Martial Arts Training Journal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Authentication Form
                if isSignUp {
                    SignUpView()
                } else {
                    LoginView()
                }
                
                Spacer()
                
                // Toggle between Login/SignUp
                Button(action: {
                    withAnimation {
                        isSignUp.toggle()
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign In")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await authService.signIn(email: email, password: password)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty)
            
            Button("Forgot Password?") {
                // Handle forgot password
            }
            .foregroundColor(.blue)
            .font(.caption)
        }
    }
}

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 15) {
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.name)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                Task {
                    await authService.signUp(email: email, password: password, displayName: displayName)
                }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(authService.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || displayName.isEmpty || password != confirmPassword)
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthService())
}
