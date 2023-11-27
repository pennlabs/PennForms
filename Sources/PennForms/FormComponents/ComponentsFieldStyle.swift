import SwiftUI

public extension View {
    func componentFormStyle(isValid: Bool, validatorMessage: String? = nil) -> some View {
        VStack(alignment: .leading) {
            self
                .padding(.vertical, 15) // Adds space inside the text field
                .padding(.horizontal, 10)
                .cornerRadius(10) // Makes the corners rounded
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isValid ? Color.secondary.opacity(0.3): Color.red , lineWidth: 2)
                )
            if !isValid, let validatorMessage {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(validatorMessage)
                }
                .foregroundColor(.red)
            }
        }
        .padding(.bottom, 5)
    }
}
