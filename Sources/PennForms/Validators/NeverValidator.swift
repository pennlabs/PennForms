public struct NeverValidator: Validator {
    public func isValid(_ input: Any) -> Bool {
        false
    }

    public let message: (Input?) -> String? = { _ in nil }
}
