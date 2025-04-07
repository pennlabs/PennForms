public struct NotNilValidator: Validator {
    public typealias Input = Any?
    public func isValid(_ input: Input) -> Bool {
        input != nil
    }

    public let message: (Input?) -> String? = { _ in "Choose an option" }
}

public extension Validator where Self == NotNilValidator {
    static var notNil: NotNilValidator { NotNilValidator() }
}
