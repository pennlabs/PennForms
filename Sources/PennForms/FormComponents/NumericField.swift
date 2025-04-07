@_spi(Advanced) import SwiftUIIntrospect
import SwiftUI

public struct NumericField<FormatStyle: ParseableFormatStyle>: FormComponent where FormatStyle.FormatInput == Decimal, FormatStyle.FormatOutput == String {
    @Binding var value: Decimal
    let placeholder: String?
    let title: String?
    let format: FormatStyle
    @Environment(\.validator) private var validator
    
    
    public init(_ value: Binding<Int?>, placeholder: String? = nil, title: String? = nil) where FormatStyle == Decimal.FormatStyle {
        self._value = Binding(get: {
            guard let v = value.wrappedValue else { return .nan }
            return Decimal(v)
        }, set: {
            value.wrappedValue = $0 == .nan ? nil : Int(($0 as NSDecimalNumber).intValue)
        })
        self.placeholder = placeholder
        self.title = title
        self.format = .number
        self._validator = Environment(\.validator)
        
        // MARK - This is making the pair bug out
        UITextField.appearance().text = placeholder ?? ""
        UITextField.appearance().textColor = .secondaryLabel
    }
    
    public init(_ value: Binding<Int?>, format: FormatStyle, placeholder: String? = nil, title: String? = nil) {
        self._value = Binding(get: {
            guard let v = value.wrappedValue else { return .nan }
            return Decimal(v)
        }, set: {
            value.wrappedValue = $0 == .nan ? nil : Int(($0 as NSDecimalNumber).intValue)
        })
        self.placeholder = placeholder
        self.title = title
        self.format = format
        self._validator = Environment(\.validator)
    }
    
    public init(_ value: Binding<Double?>, placeholder: String? = nil, title: String? = nil) where FormatStyle == Decimal.FormatStyle {
        self._value = Binding(get: {
            guard let v = value.wrappedValue else { return .nan }
            return Decimal(v)
        }, set: {
            value.wrappedValue = $0 == .nan ? nil : Double(($0 as NSDecimalNumber).doubleValue)
        })
        self.placeholder = placeholder
        self.title = title
        self.format = .number
        self._validator = Environment(\.validator)
        
        UITextField.appearance().text = placeholder ?? ""
        UITextField.appearance().textColor = .secondaryLabel
    }
    
    public init(_ value: Binding<Double?>, placeholder: String? = nil, title: String? = nil, format: FormatStyle) {
        self._value = Binding(get: {
            guard let v = value.wrappedValue else { return .nan }
            return Decimal(v)
        }, set: {
            value.wrappedValue = $0 == .nan ? nil : Double(($0 as NSDecimalNumber).doubleValue)
        })
        self.placeholder = placeholder
        self.title = title
        self.format = format
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            
            TextField(placeholder ?? " ", value: $value, format: format)
                .introspect(.textField, on: .iOS(.v16...), customize: { textField in
                    if self.value == .nan {
                        textField.text = placeholder
                    }
                    if !textField.isEditing {
                      if self.value == .nan {
                        textField.text = ""
                        textField.textColor = .secondaryLabel
                      }
                    } else {
                        textField.textColor = .label
                        
                    }
                  
                  if textField.isEditing {
                    textField.text = textField.text?.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.,").inverted)
                  }
                })
                .componentFormStyle(
                    isValid: validator.isValid(value as AnyValidator.Input), validatorMessage: validator.message(value as AnyValidator.Input)
                )
            // Bug with currency formatters, where only works if the currency symbol is deleted when entering the value
                .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                    if let textField = obj.object as? UITextField {
                        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                    }
                }
                .keyboardType(.numberPad)
        }
    }
}

extension Decimal.FormatStyle {
    struct RangeFormatter: ParseableFormatStyle {
        
        let range: ClosedRange<Decimal>
        let baseFormatter: Decimal.FormatStyle
        
        init(range: ClosedRange<Decimal>, baseFormatter: Decimal.FormatStyle) {
            self.range = range
            self.baseFormatter = baseFormatter
        }
        
        var parseStrategy: Decimal.ParseStrategy<Decimal.FormatStyle> {
            return baseFormatter.parseStrategy
        }
        
        func format(_ value: FormatInput) -> FormatOutput {
            if value > range.upperBound {
                return baseFormatter.format(range.upperBound)
            } else if value < range.lowerBound {
                return baseFormatter.format(range.lowerBound)
            } else {
                return baseFormatter.format(value)
            }
        }
    }
    
    func range(_ range: ClosedRange<Decimal>) -> RangeFormatter {
        return RangeFormatter(range: range, baseFormatter: self)
    }
    
    
}
