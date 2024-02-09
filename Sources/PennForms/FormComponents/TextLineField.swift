import SwiftUI

public struct TextLineField: FormComponent {
    @Binding var text: String
    let placeholder: String?
    let title: String?
    @Environment(\.validator) private var validator
    
    public init(_ text: Binding<String>, placeholder: String? = nil, title: String? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    public init(_ text: Binding<String?>, placeholder: String? = nil, title: String? = nil) {
        self._text = Binding(
            get: {
                guard let t = text.wrappedValue else { return "∞" }
                return t
            },
            set: { text.wrappedValue = $0 == "∞" ? nil : $0 }
        )
        self.placeholder = placeholder
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            TextField(placeholder ?? "", text: $text)
                .introspect(.textField, on: .iOS(.v16), .iOS(.v17)) { textField in
                    if textField.text == "∞" {
                        textField.text = ""
                    }
                }
                .componentFormStyle(
                    isValid: validator.isValid(text), validatorMessage: validator.message
                )
        }
    }
}
