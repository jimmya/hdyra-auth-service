import Vapor

struct HydraRedirect: Content {
    let redirectTo: String
    
    enum CodingKeys: String, CodingKey {
        case redirectTo = "redirect_to"
    }
}
