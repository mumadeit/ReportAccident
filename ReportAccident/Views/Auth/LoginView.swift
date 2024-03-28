import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                

                Text("Please Log In")
                    .font(.headline)
                
                Image("loginHeader") // Replace "loginHeader" with your image name
                    .resizable()
                    .cornerRadius(20)
                    .scaledToFit()
                
                Text("Report Accidents & Check For Insurance Companies And Breakdown Services")
                    .font(.headline)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Log In") {
                    login()
                }
                .buttonStyle(DefaultButtonStyle())

                NavigationLink("Register", destination: RegisterView())
                    .buttonStyle(DefaultButtonStyle())

                Spacer()
            }
            .padding()
        }
    }


    private func login() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/login") else {
            alertMessage = "Invalid URL"
            showingAlert = true
            return
        }

        let credentials = ["email": email, "password": password]
        guard let encoded = try? JSONEncoder().encode(credentials) else {
            alertMessage = "Failed to encode login data"
            showingAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "Login error: \(error.localizedDescription)"
                    showingAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertMessage = "No data received"
                    showingAlert = true
                }
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                DispatchQueue.main.async {
                    alertMessage = "Login successful: \(decodedResponse.user.name)"
                    showingAlert = true
                    // Here you might handle the successful login, e.g., navigating away, saving token
                    AuthenticationManager.shared.logIn()
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "Invalid response from server"
                    showingAlert = true
                }
            }
        }.resume()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
