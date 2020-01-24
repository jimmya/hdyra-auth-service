import Vapor

struct LoginPayload: Content {
    let challenge: String
    let email: String
    let password: String
}
