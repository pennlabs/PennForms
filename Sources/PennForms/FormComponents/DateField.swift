import SwiftUI

public struct DateField: FormComponent {
    
    @Binding var date: Date
    @State var isPickerVisible = false
    @Environment(\.validator) var validator
    @Environment(\.colorScheme) var colorScheme
    
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
            
            Button {
                if !isPickerVisible && date == .distantFuture {
                    date = Date()
                }
                
                isPickerVisible.toggle()
            } label: {
                HStack {
                    Group {
                        if date == .distantFuture {
                            Text(placeholder ?? "")
                                .foregroundStyle(.secondary)
                            
                        } else {
                            Text(date, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                        }
                    }
                    .tint(colorScheme == .dark ? .white : .black)

                    Spacer()
                    Image(systemName: "calendar")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, 15)
                .padding(.horizontal, 10)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(validator.isValid(date as AnyValidator.Input) ? Color.secondary.opacity(0.3): Color.red , lineWidth: 2)
                )
            }
            
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
        .popover(isPresented: $isPickerVisible) {
            NavigationStack {
                DatePicker("", selection: $date, in: self.range ?? Date.distantPast...Date.distantFuture, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)
                    .navigationTitle(title ?? "Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Done") {
                                isPickerVisible = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
