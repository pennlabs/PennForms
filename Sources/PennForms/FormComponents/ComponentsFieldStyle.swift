import SwiftUI

struct ShowValidationErrorsKey: EnvironmentKey {
    static let defaultValue = true
}

public extension EnvironmentValues {
    var showValidationErrors: Bool {
        get { self[ShowValidationErrorsKey.self] }
        set { self[ShowValidationErrorsKey.self] = newValue }
    }
}

struct ComponentFormStyleModifier: ViewModifier {
    @Environment(\.showValidationErrors) var showValidationErrors
    var isValid: Bool
    var validatorMessage: String?

    func body(content: Content) -> some View {
        let isError = showValidationErrors && !isValid

        return VStack(alignment: .leading) {
            content
                .padding(.vertical, 15) // Adds space inside the text field
                .padding(.horizontal, 10)
                .cornerRadius(10) // Makes the corners rounded
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isError ? Color.red : Color.secondary.opacity(0.3), lineWidth: 2)
                )
            if isError, let validatorMessage {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(validatorMessage)
                }
                .foregroundColor(.red)
                .preference(key: ValidPreferenceKey.self, value: false)
            }
        }
        .padding(.bottom, 5)
    }
}

public extension View {
    func componentFormStyle(isValid: Bool, validatorMessage: String? = nil) -> some View {
        modifier(ComponentFormStyleModifier(isValid: isValid, validatorMessage: validatorMessage))
    }
}
