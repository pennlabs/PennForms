import SwiftUI

public struct FormGroup<Content: FormComponent>: FormComponent {
    let title: String?
    @FormBuilder let content: () -> Content
    @Environment(\.validator) private var validator
    
    public init(title: String, @FormBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    public init(@FormBuilder content: @escaping () -> Content) {
        self.title = nil
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            content()
        }
    }
}

public extension FormGroup {
    func groupValidator(_ isValid: @escaping () -> Bool) -> some FormComponent {
        ComponentWrapper {
            VStack(alignment: .leading) {
                if !isValid() {
                    self
                     .validator(AnyValidator { false })
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle")
                        Text(validator.message(nil) ?? "Enter a valid input")
                    }
                    .foregroundColor(.red)
                } else {
                    self
                }
            }
        }
    }
}
