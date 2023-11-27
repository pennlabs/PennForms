public struct NeverValidator: Validator {
    public func isValid(_ input: Any) -> Bool {
        false
    }
    
    public let message: String? = nil
}
