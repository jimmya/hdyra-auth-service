@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testLogin() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        // Inject userClient somehow?
        
        try app.test(.POST, "auth/login") { res in
            // Assert userClient being invoked
        }
    }
}

extension Application {
    
    var hydraClient: HydraClient {
        return MockHydraClient()
    }
}

final class MockHydraClient: HydraClient {
    var invokedGetLoginRequest = false
    var invokedGetLoginRequestCount = 0
    var invokedGetLoginRequestParameters: (challenge: String, request: Request)?
    var invokedGetLoginRequestParametersList = [(challenge: String, request: Request)]()
    var stubbedGetLoginRequestResult: EventLoopFuture<HydraLoginRequest>!
    func getLoginRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraLoginRequest> {
        invokedGetLoginRequest = true
        invokedGetLoginRequestCount += 1
        invokedGetLoginRequestParameters = (challenge, request)
        invokedGetLoginRequestParametersList.append((challenge, request))
        return stubbedGetLoginRequestResult
    }
    var invokedAcceptLoginRequest = false
    var invokedAcceptLoginRequestCount = 0
    var invokedAcceptLoginRequestParameters: (loginRequest: HydraLoginRequest, request: Request)?
    var invokedAcceptLoginRequestParametersList = [(loginRequest: HydraLoginRequest, request: Request)]()
    var stubbedAcceptLoginRequestResult: EventLoopFuture<HydraRedirect>!
    func acceptLoginRequest(loginRequest: HydraLoginRequest, on request: Request) -> EventLoopFuture<HydraRedirect> {
        invokedAcceptLoginRequest = true
        invokedAcceptLoginRequestCount += 1
        invokedAcceptLoginRequestParameters = (loginRequest, request)
        invokedAcceptLoginRequestParametersList.append((loginRequest, request))
        return stubbedAcceptLoginRequestResult
    }
    var invokedAcceptLoginRequestChallenge = false
    var invokedAcceptLoginRequestChallengeCount = 0
    var invokedAcceptLoginRequestChallengeParameters: (challenge: String, id: UUID, request: Request)?
    var invokedAcceptLoginRequestChallengeParametersList = [(challenge: String, id: UUID, request: Request)]()
    var stubbedAcceptLoginRequestChallengeResult: EventLoopFuture<HydraRedirect>!
    func acceptLoginRequest(challenge: String, id: UUID, on request: Request) -> EventLoopFuture<HydraRedirect> {
        invokedAcceptLoginRequestChallenge = true
        invokedAcceptLoginRequestChallengeCount += 1
        invokedAcceptLoginRequestChallengeParameters = (challenge, id, request)
        invokedAcceptLoginRequestChallengeParametersList.append((challenge, id, request))
        return stubbedAcceptLoginRequestChallengeResult
    }
    var invokedGetConsentRequest = false
    var invokedGetConsentRequestCount = 0
    var invokedGetConsentRequestParameters: (challenge: String, request: Request)?
    var invokedGetConsentRequestParametersList = [(challenge: String, request: Request)]()
    var stubbedGetConsentRequestResult: EventLoopFuture<HydraConsentRequest>!
    func getConsentRequest(challenge: String, on request: Request) -> EventLoopFuture<HydraConsentRequest> {
        invokedGetConsentRequest = true
        invokedGetConsentRequestCount += 1
        invokedGetConsentRequestParameters = (challenge, request)
        invokedGetConsentRequestParametersList.append((challenge, request))
        return stubbedGetConsentRequestResult
    }
    var invokedAcceptConsentRequest = false
    var invokedAcceptConsentRequestCount = 0
    var invokedAcceptConsentRequestParameters: (consentRequest: HydraConsentRequest, request: Request)?
    var invokedAcceptConsentRequestParametersList = [(consentRequest: HydraConsentRequest, request: Request)]()
    var stubbedAcceptConsentRequestResult: EventLoopFuture<HydraRedirect>!
    func acceptConsentRequest(consentRequest: HydraConsentRequest, on request: Request) -> EventLoopFuture<HydraRedirect> {
        invokedAcceptConsentRequest = true
        invokedAcceptConsentRequestCount += 1
        invokedAcceptConsentRequestParameters = (consentRequest, request)
        invokedAcceptConsentRequestParametersList.append((consentRequest, request))
        return stubbedAcceptConsentRequestResult
    }
}
