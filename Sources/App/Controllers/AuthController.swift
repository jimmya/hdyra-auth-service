import Vapor
import AsyncHTTPClient
import CSRF

struct AuthController: RouteCollection {
    
    private let userClient: UserClient
    private let hydraClient: HydraClient
    
    private let csrf = CSRF()
    
    init(userClient: UserClient, hydraClient: HydraClient) {
        self.userClient = userClient
        self.hydraClient = hydraClient
    }
    
    func boot(routes: RoutesBuilder) throws {
        let authRouter = routes.grouped("auth")
        authRouter.get("register", use: renderRegister)
        authRouter.get("login", use: renderLogin)
        authRouter.get("consent", use: skipConsent)
        authRouter.post("register", use: register)
        authRouter.post("login", use: login)
    }
}

private extension AuthController {
    
    func renderRegister(req: Request) throws -> EventLoopFuture<Response> {
        return renderAuth(request: req, type: .register)
    }
    
    func renderLogin(req: Request) throws -> EventLoopFuture<Response> {
        return renderAuth(request: req, type: .login)
    }
    
    func skipConsent(req: Request) throws -> EventLoopFuture<Response> {
        let challenge = try req.query.get(String.self, at: HydraRequestType.consent.challengeKey)
        return hydraClient.getConsentRequest(challenge: challenge, on: req).flatMap { consentRequest in
            return self.hydraClient.acceptConsentRequest(consentRequest: consentRequest, on: req).map { redirect in
                return req.redirect(to: redirect.redirectTo)
            }
        }
    }
    
    func register(req: Request) throws -> EventLoopFuture<Response> {
        fatalError()
    }
    
    func login(req: Request) throws -> EventLoopFuture<Response> {
        let payload = try req.content.decode(LoginPayload.self)
        return userClient.findUser(identifier: payload.email, password: payload.password, on: req).flatMap { loginResponse in
            return self.hydraClient.acceptLoginRequest(challenge: payload.challenge, id: loginResponse.id, on: req).map { redirect in
                return req.redirect(to: redirect.redirectTo)
            }
        }.flatMapError { error in
            var msg = error.localizedDescription
            if let error = error as? AbortError {
                msg = error.reason
            }
            return self.renderAuth(request: req, type: .login, errorMsg: msg, challenge: payload.challenge)
        }
    }
}

private extension AuthController {
    
    private func renderAuth(request req: Request, type: AuthType, errorMsg: String = "", challenge: String? = nil) -> EventLoopFuture<Response> {
        do {
            let challenge = try (challenge ?? req.query.get(String.self, at: HydraRequestType.login.challengeKey))
            return hydraClient.getLoginRequest(challenge: challenge, on: req).flatMap { loginRequest in
                if loginRequest.skip {
                    return self.hydraClient.acceptLoginRequest(loginRequest: loginRequest, on: req).map { redirect in
                        return req.redirect(to: redirect.redirectTo)
                    }
                } else {
                    return self.renderAuthForm(request: req, challenge: loginRequest.challenge, type: type, errorMsg: errorMsg)
                }
            }
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }

    private func renderAuthForm(request req: Request, challenge: String, type: AuthType, errorMsg: String) -> EventLoopFuture<Response> {
        guard let oauthCsrf = req.cookies["oauth2_authentication_csrf"]?.string else {
            return req.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "Login request hydra cookie is missing" , identifier: nil))
        }
        req.session.data["CSRFSecret"] = oauthCsrf
        let csrfToken = csrf.createToken(from: req)
        let viewVariables = ["csrfToken": csrfToken, "challenge": challenge, "errorMessage": errorMsg]
        return req.view.render(type.rawValue, viewVariables).flatMap { view in
            return view.encodeResponse(for: req)
        }
    }
}
