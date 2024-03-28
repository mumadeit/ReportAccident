import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Register")
                    .font(.headline)

                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Register") {
                    register()
                }
                .buttonStyle(DefaultButtonStyle())

                Spacer()
            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Registration Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func register() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/register") else {
            alertMessage = "Invalid URL"
            showingAlert = true
            return
        }

        let data = RegistrationData(name: name, email: email, password: password)
        guard let encoded = try? JSONEncoder().encode(data) else {
            alertMessage = "Failed to encode registration data"
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
                    alertMessage = "HTTP Request Failed: \(error.localizedDescription)"
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

            if let decodedResponse = try? JSONDecoder().decode(RegistrationResponse.self, from: data) {
                DispatchQueue.main.async {
                    alertMessage = "Registration successful: \(decodedResponse.user.name)"
                    showingAlert = true
                    // Here you could also handle navigation or token storage.
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
