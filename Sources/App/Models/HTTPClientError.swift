import Vapor

struct HTTPClientError: AbortError {
    
    var status: HTTPResponseStatus
    var reason: String
    var file: String
    var function: String
    var line: UInt
    var column: UInt
    
    /// the `AbortError` protocol.
    var source: ErrorSource? {
        return .init(file: self.file, line: self.line, function: self.function)
    }
    
    var description: String {
        return "HTTPClient error \(self.status.code): \(self.reason)"
    }
    
    /// Create a new `HTTPClientError`, capturing current source location info.
    public init(
        _ status: HTTPResponseStatus,
        reason: String? = nil,
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.status = status
        self.reason = reason ?? status.reasonPhrase
        self.file = file
        self.function = function
        self.line = line
        self.column = column
    }
    
    static var noResponseBody: HTTPClientError {
        .init(.internalServerError, reason: "Service returned no response body")
    }
    
    static var responseError: HTTPClientError {
        .init(.internalServerError, reason: "Service returned invalid status code")
    }
}
