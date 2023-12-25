import SwiftUI

public struct TextAreaField: FormComponent {
    @Binding var text: String
    
    let title: String?
    let characterCount: Int?
    
    @Environment(\.validator) var validator
    
    init(_ text: Binding<String>, characterCount: Int? = nil, title: String? = nil) {
        self._text = text
        self.characterCount = characterCount
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    init(_ text: Binding<String?>, characterCount: Int? = nil, title: String? = nil) {
        self._text = Binding(
            get: {
                guard let t = text.wrappedValue else { return "∞" }
                return t
            },
            set: { text.wrappedValue = $0 == "∞" ? nil : $0 }
        )
        self.characterCount = characterCount
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            TextEditor(text: $text)
                .introspect(.textEditor, on: .iOS(.v16), .iOS(.v17)) { textEditor in
                    if textEditor.text == "∞" {
                        self.text = ""
                    }
                }
                .frame(minHeight: 80)
                .cornerRadius(10) // Makes the corners rounded
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(validator.isValid(text) ? Color.secondary.opacity(0.3): Color.red , lineWidth: 2)
                }
            
            HStack(spacing: 5) {
                Group {
                    if !validator.isValid(text), let validatorMessage = validator.message {
                        Image(systemName: "exclamationmark.circle")
                        Text(validatorMessage)
                    }
                }
                .foregroundColor(.red)
                .preference(key: ValidPreferenceKey.self, value: false)
                
                if let characterCount {
                    Spacer()
                    Text("\(characterCount - text.count) characters remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: text) { _ in
            if let characterCount, text.count > characterCount {
                text.removeLast(text.count - characterCount)
            }
        }
        .padding(.bottom, 5)
    }
}

