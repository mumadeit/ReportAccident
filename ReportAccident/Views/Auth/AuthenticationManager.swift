import Foundation

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    @Published var isLoggedIn: Bool = false

    private init() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func logIn() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        isLoggedIn = true
    }

    func logOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        isLoggedIn = false
    }
}

class UserSession: ObservableObject {
    static let shared = UserSession()
    @Published var userID: Int?
    @Published var accessToken: String?
}


