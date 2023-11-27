public struct NotNilValidator: Validator {
    public typealias Input = Any?
    public func isValid(_ input: Input) -> Bool {
        input != nil
    }
    
    public var message: String? = "Choose an option"
}

public extension Validator where Self == NotNilValidator {
    static var notNil: NotNilValidator {  NotNilValidator() }
}
