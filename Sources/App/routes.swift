import Vapor

func routes(_ app: Application) throws {
    
    app.get("status") { req -> HTTPStatus in
        return .ok
    }
    
    let authController = AuthController(userClient: app.userClient, hydraClient: app.hydraClient)
    try app.register(collection: authController)
}
