import SwiftUI

public struct DateRangeField: FormComponent {
    
    @Binding var lowerDate: Date
    @Binding var upperDate: Date
    @State var wasSet: Bool = false
    @Environment(\.validator) var validator
    
    let range: ClosedRange<Date>
    let upperOffset: Int
    let title: String?
    let lowerPlaceholder: String?
    let upperPlaceholder: String?
    
    init(lowerDate: Binding<Date?>, upperDate: Binding<Date?>, in range: ClosedRange<Date>? = nil, upperOffset: Int = 0, title: String? = nil, lowerPlaceholder: String? = nil, upperPlaceholder: String? = nil) {
        self._lowerDate = Binding(
            get: {
                guard let d = lowerDate.wrappedValue else { return .distantPast }
                return d
            },
            set: {
                lowerDate.wrappedValue = $0 == .distantPast ? nil : $0
            }
        )
        self._upperDate = Binding(
            get: {
                guard let d = upperDate.wrappedValue else { return .distantFuture }
                return d
            },
            set: {
                upperDate.wrappedValue = $0 == .distantFuture ? nil : $0
            }
        )
        self.range = range ?? Date.distantPast...Date.distantFuture
        self.upperOffset = upperOffset
        self.title = title
        self.lowerPlaceholder = lowerPlaceholder
        self.upperPlaceholder = upperPlaceholder
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            HStack {
                dateField(date: $lowerDate, in: self.range.lowerBound...upperDate, placeholder: lowerPlaceholder)
                dateField(date: $upperDate, in: lowerDate...self.range.upperBound, placeholder: upperPlaceholder)
            }
            
            if !validator.isValid(lowerDate as AnyValidator.Input) || !validator.isValid(upperDate as AnyValidator.Input), let validatorMessage = validator.message {
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
            self.lowerDate = self.range.lowerBound == .distantPast ? .now : self.range.lowerBound
            self.upperDate = Calendar.current.date(byAdding: .day, value: upperOffset, to: .now) ?? (self.range.upperBound == .distantFuture ? .now : self.range.upperBound)
        }
    }
    
    func dateField(date: Binding<Date>, in range: ClosedRange<Date>, placeholder: String? = nil) -> some View {
        HStack {
            Group {
                if date.wrappedValue == .distantFuture || date.wrappedValue == .distantPast {
                    Text(placeholder ?? "")
                        .foregroundStyle(.secondary)
                    
                } else {
                    Text(date.wrappedValue, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                }
            }
            Spacer()
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(.blue)
                .overlay {
                    DatePicker("", selection: date, in: range, displayedComponents: [.date])
                        .onTapGesture {
                            self.wasSet = true
                        }
                        .overlay(alignment: .bottomTrailing, content: {
                            Button(action: { date.wrappedValue = range.lowerBound == .distantPast ? .distantPast : .distantFuture}) {
                                Image(systemName: "x.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        })
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
    }
}
