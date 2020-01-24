import Vapor
import AsyncHTTPClient

protocol UserClient {
    
    func findUser(identifier: String, password: String, on request: Request) -> EventLoopFuture<GetUserResponse>
}

final class RemoteUserClient: UserClient {
    
    private let host: String
    
    init(host: String) {
        self.host = host
    }
    
    func findUser(identifier: String, password: String, on request: Request) -> EventLoopFuture<GetUserResponse> {
        let url = host + "/users/login"
        let requestBody = LoginRequest(identifier: identifier, password: password)
        return request.client.post(.init(string: url), headers: [:]) { request in
            try request.content.encode(requestBody)
        }.flatMapThrowing { response in
            guard response.status == .ok else {
                throw HTTPClientError.responseError
            }
            return try response.content.decode(GetUserResponse.self)
        }
    }
}
