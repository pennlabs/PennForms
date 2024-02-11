import OrderedCollections
import SwiftUI

public struct FormState {
  public var isValid: Bool
  
  public init(isValid: Bool) {
    self.isValid = isValid
  }
}

public struct LabsForm<Content: FormComponent>: View {
  @FormBuilder let content: (FormState) -> Content
  @State private var formState: FormState = .init(isValid: true)
  
  public init(@FormBuilder content: @escaping (FormState) -> Content) {
    self.content = content
  }
  
  public var body: some View {
    content(formState)
      .onPreferenceChange(ValidPreferenceKey.self) { isValid in
        formState.isValid = isValid
      }
      .padding()
  }
}

extension HStack: FormComponent {}
extension VStack: FormComponent {}
extension TextField: FormComponent {}
extension Text: FormComponent {}



struct TestForm: View {
  
  @State private var name: String?
  @State private var description: String?
  @State private var date1: Date? = nil
  @State private var date2: Date? = nil
  @State private var date3: Date? = nil
  @State private var numRommates: Int? = nil
  @State private var negotiable: Negotiable? = nil
  @State private var price1: Double? = nil
  @State private var price2: Double? = nil
  @State private var price3: Double? = nil
  @State private var selectedAmenities: OrderedSet<String> = []
  
  @State private var amenities: OrderedSet = ["Gym", "Private bathroom", "asd", "asdas", "qweuh"]
  
  var dateRange: ClosedRange<Date> {
    let upper = Calendar.current.date(byAdding: .init(day: 5), to: .now)!
    return .now...upper
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        LabsForm { formState in
          TextLineField($name, placeholder: "Name")
            .validator(.required)
          
          TextAreaField($description, characterCount: 15, title: "Description")
            .validator(.required)
          
          DateRangeField(
            lowerDate: $date1,
            upperDate: $date2,
            in: dateRange,
            upperOffset: 3,
            title: "Personal information",
            lowerPlaceholder: "Start date",
            upperPlaceholder: "End date"
          )
          .validator(.required)
          
          DateField(date: $date3, placeholder: "Date of birth")
            .validator(.required)
          
          PairFields {
            OptionField($numRommates, range: 0...4, title: "# roommates")
              .validator(.required)
            OptionField(
              $negotiable,
              options: Negotiable.allCases, title: "Negotiable?"
            )
            .validator(.required)
          }
          NumericField(
            $price1,
            title: "Price",
            format: .currency(code: "USD").presentation(.narrow)
          )
          
          NumericField(
            $price2,
            title: "Pricekhg",
            format: .currency(code: "USD").presentation(.narrow)
          )
          
          NumericField(
            $price3,
            title: "Pricekhg",
            format: .currency(code: "USD").presentation(.narrow)
          )
          
          TagSelector(selection: $selectedAmenities, tags: $amenities, customisable: .customisable(tagFromString: { $0}), title: "Amenities")
            .validator(.required)
          
          ComponentWrapper {
            Button(action: {}) {
              Text("Submit")
                .font(.title3)
                .bold()
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(in: Capsule())
            .foregroundStyle(.white)
            .backgroundStyle(formState.isValid ? .blue : .gray)
            .padding(.horizontal, 30)
            .padding(.top, 30)
            .disabled(!formState.isValid)
          }
        }
      }
      .navigationTitle("Info form")
    }
  }
}

enum Negotiable: String, CaseIterable {
  case yes = "Yes"
  case no = "No"
}

#Preview {
  TestForm()
}
