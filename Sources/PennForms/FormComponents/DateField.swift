import SwiftUI

public struct DateField: FormComponent {
    
    @Binding var date: Date
    @State var wasSet: Bool = false
    @Environment(\.validator) var validator
    
    let range: ClosedRange<Date>?
    let title: String?
    let placeholder: String?
    
    public init(date: Binding<Date?>, in range: ClosedRange<Date>? = nil, title: String? = nil, placeholder: String? = nil) {
        self._date = Binding(
            get: {
                guard let d = date.wrappedValue else { return .distantFuture }
                return d
            },
            set: {
                date.wrappedValue = $0 == .distantFuture ? nil : $0
            }
        )
        self.range = range
        self.title = title
        self.placeholder = placeholder
        self._validator = Environment(\.validator)
    }
    
    public init(date: Binding<Date>, in range: ClosedRange<Date>? = nil, title: String? = nil, placeholder: String? = nil) {
        self._date = date
        self.range = range
        self.title = title
        self.placeholder = placeholder
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            HStack {
                Group {
                    if date == .distantFuture {
                        Text(placeholder ?? "")
                            .foregroundStyle(.secondary)
                        
                    } else {
                        Text(date, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                    }
                }
                Spacer()
                Image(systemName: "calendar")
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .overlay {
                        DatePicker("", selection: $date, in: self.range ?? Date.distantPast...Date.distantFuture, displayedComponents: [.date])
                            .onTapGesture {
                                self.wasSet = true
                            }
                            .blendMode(.destinationOver)
                    }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(validator.isValid(date as AnyValidator.Input) ? Color.secondary.opacity(0.3): Color.red , lineWidth: 2)
            )
            
            if !validator.isValid(date as AnyValidator.Input), let validatorMessage = validator.message {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(validatorMessage)
                }
                .foregroundColor(.red)
                .preference(key: ValidPreferenceKey.self, value: false)
            }
        }
        .padding(.bottom, 5)
        .onChange(of: wasSet) { _ in
            self.date = .now
        }
    }
}
