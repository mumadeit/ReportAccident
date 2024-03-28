struct RegistrationResponse: Codable {
    var access_token: String
    var token_type: String
    var user: User
}

struct LoginResponse: Codable {
    var access_token: String
    var user: User
}

struct User: Codable {
    var id: Int
    var name: String
    var email: String
}


