import Foundation
import OrderedCollections

public struct RequiredValidator: Validator {
    public let message: String?
    
    public init(_ message: String = "Required field") {
        self.message = message
    }
    
    public typealias Input = Any
    public func isValid(_ input: Any) -> Bool {

        if let input = input as? (any HasEmpty) {
            return !input.empty
        } else if let input = input as? Optional<Any> {
            return input != nil
        } else {
            return true
        }
        
    }
    
}

public extension Validator where Self == RequiredValidator {
    static var required: Self { RequiredValidator() }
    
    func required(_ message: String) -> Self { RequiredValidator(message) }
}

public protocol HasEmpty {
    var empty: Bool { get }
}

extension String: HasEmpty {
    public var empty: Bool {
        self == "" || self == "∞"
    }
}

extension Decimal: HasEmpty {
    public var empty: Bool {
        self == .nan
    }
}

extension Date: HasEmpty {
    public var empty: Bool {
        self == .distantPast || self == .distantFuture
    }
}

extension OrderedSet: HasEmpty {
    public var empty: Bool {
        self.isEmpty
    }
}
