import SwiftUI

public struct ManyValidators: Validator {
    public typealias Input = Any
    let validators: [AnyValidator]
    
    public init(_ validators: [AnyValidator]) {
        self.validators = validators
        self.message =  validators[0].message
    }
    
    public func isValid(_ input: Input) -> Bool {
        return validators.allSatisfy { $0.isValid(input) }
    }
    
    public var message: String?
}

public extension View {
    func validator(_ validators: [AnyValidator]) -> some FormComponent {
        ComponentWrapper { self.environment(\.validator, .any(ManyValidators(validators))) }
    }
}

public extension Validator where Self == ManyValidators {
    static func many(_ validators: [AnyValidator]) -> ManyValidators {
        return ManyValidators(validators)
    }
}
