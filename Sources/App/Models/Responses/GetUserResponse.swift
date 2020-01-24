import Vapor

struct GetUserResponse: Content {
    
    let id: UUID
}

extension GetUserResponse: Equatable { }
