import SwiftUI

public struct ManyValidators: Validator {
    public typealias Input = Any
    public let message: (Input?) -> String?
    let validators: [AnyValidator]

    public init(_ validators: [AnyValidator]) {
        self.validators = validators
        self.message = { input in
            guard let input else { return nil }
            if let firstFailure = validators.first(where: { !$0.isValid(input) }) {
                return firstFailure.message(input)
            } else {
                return nil
            }
        }
    }

    public func isValid(_ input: Input) -> Bool {
        return validators.allSatisfy { $0.isValid(input) }
    }
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
