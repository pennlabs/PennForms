import SwiftUI

public struct DateRangeField: FormComponent {

    @Binding var lowerDate: Date
    @Binding var upperDate: Date
    @State var wasSet1: Bool = false
    @State var wasSet2: Bool = false
    @Environment(\.validator) var validator
    @Environment(\.showValidationErrors) var showValidationErrors

    let range: ClosedRange<Date>
    let upperOffset: Int
    let title: String?
    let lowerPlaceholder: String?
    let upperPlaceholder: String?

    public init(lowerDate: Binding<Date?>, upperDate: Binding<Date?>, in range: ClosedRange<Date>? = nil, upperOffset: Int = 0, title: String? = nil, lowerPlaceholder: String? = nil, upperPlaceholder: String? = nil) {
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
                let begin = max(lowerDate, range.lowerBound)
                let end = min(upperDate, range.upperBound)
                let validBegin = min(range.upperBound, begin)
                let validEnd = max(range.lowerBound, end)
                DateRangeSubfield(date: $lowerDate, range: self.range.lowerBound...validEnd, placeholder: lowerPlaceholder, wasSet: $wasSet1)
                DateRangeSubfield(date: $upperDate, range: validBegin...self.range.upperBound, placeholder: upperPlaceholder, wasSet: $wasSet2)
            }

            if showValidationErrors, !validator.isValid(lowerDate as AnyValidator.Input) || !validator.isValid(upperDate as AnyValidator.Input), let validatorMessage = validator.message(lowerDate as AnyValidator.Input) ?? validator.message(upperDate as AnyValidator.Input) {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(validatorMessage)
                }
                .foregroundColor(.red)
                .preference(key: ValidPreferenceKey.self, value: false)
            }
        }
        .padding(.bottom, 5)
        .onChange(of: wasSet1) { _ in
            self.lowerDate = self.range.lowerBound == .distantPast ? .now : self.range.lowerBound
        }
        .onChange(of: wasSet2) { _ in
            self.upperDate = Calendar.current.date(byAdding: .day, value: upperOffset, to: .now) ?? (self.range.upperBound == .distantFuture ? .now : self.range.upperBound)
        }
    }
}

private struct DateRangeSubfield: View {
    @Binding var date: Date
    var range: ClosedRange<Date>
    var placeholder: String?
    @Binding var wasSet: Bool

    @Environment(\.validator) var validator
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.showValidationErrors) var showValidationErrors
    @State var isPickerVisible = false

    var body: some View {
        Button {
            isPickerVisible.toggle()
            wasSet = true
        } label: {
            HStack {
                Group {
                    if date == .distantPast || date == .distantFuture {
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
                    .stroke(!showValidationErrors || validator.isValid(date as AnyValidator.Input) ? Color.secondary.opacity(0.3): Color.red, lineWidth: 2)
            )
        }
        .popover(isPresented: $isPickerVisible) {
            DatePickerPopover(date: $date, range: range, title: placeholder)
        }
    }
}
