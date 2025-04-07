import SwiftUI

public protocol Validator<Input> {
    associatedtype Input
    func isValid(_ input: Input) -> Bool

    // This is a function because the message might depend on the input
    // For example, in ManyValidator, the first validator might pass, while the second fails
    // Thus we need to show the second validator's message (hence it is input dependent)
    var message: (Input?) -> String? { get }
}

public extension Validator {
    func callAsFunction(input: Input) -> Bool {
        return isValid(input)
    }
}

public struct ValidatorKey: EnvironmentKey {
    public static let defaultValue: AnyValidator = AnyValidator(AlwaysValidator())
}

public extension EnvironmentValues {
    var validator: AnyValidator {
        get { self[ValidatorKey.self] }
        set { self[ValidatorKey.self] = newValue }
    }
}

public extension View {
    func validator<V: Validator>(_ validator: V) -> some FormComponent where V.Input: Any {
        ComponentWrapper { self.environment(\.validator, AnyValidator(validator)) }
    }

    func validator(_ isValid: @escaping () -> Bool, message: String? = nil) -> some FormComponent {
        ComponentWrapper { self.environment(\.validator, AnyValidator(isValid, message: message)) }
    }
}

public extension Validator where Self == AlwaysValidator {
    static var always: AlwaysValidator { AlwaysValidator() }
}

public extension Validator where Self == NeverValidator {
    static var never: NeverValidator { NeverValidator() }
}

public enum ValidPreferenceKey: PreferenceKey {
    static public var defaultValue: Bool = true
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        if !value {
            return
        } else {
            value = nextValue()
        }
    }
}
