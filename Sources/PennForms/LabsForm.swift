import OrderedCollections
import SwiftUI

public struct LabsForm<Content: FormComponent>: View {
    @FormBuilder let content: () -> Content
    
    init(@FormBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding()
    }
}

extension HStack: FormComponent {}
extension VStack:  FormComponent {}
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
    @State private var price: Double? = nil
    @State private var selectedAmenities: OrderedSet<String> = []
    
    @State private var amenities: OrderedSet = ["Gym", "Private bathroom", "asd", "asdas", "qweuh"]
    
    var dateRange: ClosedRange<Date> {
        let upper = Calendar.current.date(byAdding: .init(day: 5), to: .now)!
        return .now...upper
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LabsForm {
                    TextLineField($name, placeholder: "Name")
                    
                    TextAreaField($description, characterCount: 15, title: "Description")
                    
                    DateRangeField(
                        lowerDate: $date1,
                        upperDate: $date2,
                        in: dateRange,
                        upperOffset: 3,
                        title: "Personal information",
                        lowerPlaceholder: "Start date",
                        upperPlaceholder: "End date"
                    )
                    
                    DateField(date: $date3, placeholder: "Date of birth")
                    
                    PairFields {
                        OptionField($numRommates, range: 0...4, title: "# roommates")
                        OptionField(
                            $negotiable,
                            options: Negotiable.allCases, title: "Negotiable?"
                        )
                    }
                    
                    NumericField(
                        $price,
                        title: "Price",
                        format: .currency(code: "USD").presentation(.narrow)
                    )
                    
                    TagSelector(selection: $selectedAmenities, tags: $amenities, customisable: .customisable(tagFromString: { $0}), title: "Amenities")
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
