import Vapor
import Leaf
import Metrics

// Called before your application initializes.
func configure(_ app: Application) throws {
    if app.environment == .development {
        app.server.configuration.port = 8080
    }
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    
    app.views.use(.leaf)
    
    try routes(app)
}

extension Application {
    
    var userClient: UserClient {
        guard let userHost = Environment.get("USER_HOST") else {
            fatalError("USER_HOST env value not set")
        }
        return RemoteUserClient(host: userHost)
    }
    
    var hydraClient: HydraClient {
        guard let hydraHost = Environment.get("HYDRA_HOST") else {
            fatalError("HYDRA_HOST env value not set")
        }
        return RemoteHydraClient(host: hydraHost)
    }
}
