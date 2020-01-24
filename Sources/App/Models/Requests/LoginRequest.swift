import Vapor

struct LoginRequest: Content {
    
    let identifier: String
    let password: String
    
    init(identifier: String, password: String) {
        self.identifier = identifier
        self.password = password
    }
}

extension LoginRequest: Equatable { }
