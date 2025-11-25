import Foundation

public struct Test {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public func sayHello() -> String {
        return "Hello, \(message)!"
    }
}
