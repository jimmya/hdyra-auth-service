import Vapor

enum HydraRequestType: String {
    case login
    case consent
    
    var challengeKey: String {
        switch self {
        case .login: return "login_challenge"
        case .consent: return "consent_challenge"
        }
    }
}
