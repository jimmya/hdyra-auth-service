import Vapor
import AsyncHTTPClient

protocol HydraClient {
    
    func getLoginRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraLoginRequest>
    func acceptLoginRequest(loginRequest: HydraLoginRequest, on request: Request) -> EventLoopFuture<HydraRedirect>
    func acceptLoginRequest(challenge: String, id: UUID, on request: Request) -> EventLoopFuture<HydraRedirect>
    func getConsentRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraConsentRequest>
    func acceptConsentRequest(consentRequest: HydraConsentRequest, on request: Request) -> EventLoopFuture<HydraRedirect>
}

final class RemoteHydraClient: HydraClient {
    
    private let host: String
    
    init(host: String) {
        self.host = host
    }
    
    func getLoginRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraLoginRequest> {
        let endpoint = getHydraRequestEndpoint(for: .login, challenge: challenge)
        return request.client.get(.init(string: endpoint)).flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(HydraLoginRequest.self)
        }
    }
    
    func acceptLoginRequest(loginRequest: HydraLoginRequest, on request: Request) -> EventLoopFuture<HydraRedirect> {
        let endpoint = getHydraAcceptRequestEndpoint(for: .login, challenge: loginRequest.challenge)
        return request.client.put(.init(string: endpoint), headers: [:]) { request in
            try request.content.encode(loginRequest.alwaysRememberAcceptPayload)
        }.flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(HydraRedirect.self)
        }
    }
    
    func acceptLoginRequest(challenge: String, id: UUID, on request: Request) -> EventLoopFuture<HydraRedirect> {
        let body = HydraAcceptLoginRequestPayload(remember: true, rememberFor: 0, subject: id.uuidString)
        let endpoint = getHydraAcceptRequestEndpoint(for: .login, challenge: challenge)
        return request.client.put(.init(string: endpoint), headers: [:]) { request in
            try request.content.encode(body)
        }.flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(HydraRedirect.self)
        }
    }
    
    func getConsentRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraConsentRequest> {
        let endpoint = getHydraRequestEndpoint(for: .consent, challenge: challenge)
        return request.client.get(.init(string: endpoint)).flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(HydraConsentRequest.self)
        }
    }
    
    func acceptConsentRequest(consentRequest: HydraConsentRequest, on request: Request) -> EventLoopFuture<HydraRedirect> {
        let endpoint = getHydraAcceptRequestEndpoint(for: .consent, challenge: consentRequest.challenge)
        return request.client.put(.init(string: endpoint), headers: [:]) { request in
            try request.content.encode(consentRequest.alwaysRememberAcceptPayload)
        }.flatMapThrowing { response in
            request.logger.debug("Response: \(response)")
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(HydraRedirect.self)
        }
    }
}

private extension RemoteHydraClient {
    
    private func getHydraRequestEndpoint(for type: HydraRequestType, challenge: String) -> String {
        return "\(host)/oauth2/auth/requests/\(type.rawValue)?\(type.challengeKey)=\(challenge)"
    }
    
    private func getHydraAcceptRequestEndpoint(for type: HydraRequestType, challenge: String) -> String {
        return "\(host)/oauth2/auth/requests/\(type.rawValue)/accept?\(type.challengeKey)=\(challenge)"
    }
}
