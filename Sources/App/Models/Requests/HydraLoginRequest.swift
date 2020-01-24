import Vapor

struct HydraLoginRequest: Content {
    let challenge: String
    let skip: Bool
    let subject: String?
    
    var alwaysRememberAcceptPayload: HydraAcceptLoginRequestPayload {
        return HydraAcceptLoginRequestPayload(remember: !skip, rememberFor: 0, subject: subject)
    }
}

struct HydraAcceptLoginRequestPayload: Content {
    let remember: Bool
    let rememberFor: Int64
    let subject: String?
    
    enum CodingKeys: String, CodingKey {
        case remember
        case rememberFor = "remember_for"
        case subject
    }
}
