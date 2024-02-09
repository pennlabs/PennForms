public struct AnyValidator: Validator {
    public typealias Input = Any
    let validator: (Any) -> Bool
    public let message: String?
    
    public func isValid(_ input: Input) -> Bool {
        self.validator(input)
    }
    
    public init<V: Validator>(_ validator: V) where V.Input: Any {
        self.validator = { input in
            guard let castInput = input as? V.Input else { return false}
            return validator.isValid(castInput)
        }
        self.message = validator.message
    }
    
    public init(_ isValid: @escaping () -> Bool, message: String? = nil) {
        self.validator = { _ in isValid() }
        self.message = message
        
    }
}


public extension Validator where Self == AnyValidator {
    static func `any`<V: Validator>(_ validator: V) -> AnyValidator {
        return AnyValidator(validator)
    }
}
