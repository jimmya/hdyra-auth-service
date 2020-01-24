import Vapor

func routes(_ app: Application) throws {
    
    let authController = AuthController(userClient: app.userClient, hydraClient: app.hydraClient)
    try app.register(collection: authController)
}
