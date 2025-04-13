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
    @State var selectedImages: [UIImage] = []
    @State var existingImages: [String] = []
    @State private var description: String?
    @State private var date1: Date?
    @State private var date2: Date?
    @State private var date3: Date?
    @State private var numRommates: Int?
    @State private var negotiable: Negotiable?
    @State private var price: Double?
    @State private var selectedAmenities: OrderedSet<String> = []

    @State private var amenities: OrderedSet = ["Gym", "Private bathroom", "asd", "asdas", "qweuh"]

    @State var showValidationErrors = false

    var dateRange: ClosedRange<Date> {
        let upper = Date.distantFuture
        return .now...upper
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LabsForm { formState in
                    TextLineField($name, placeholder: "Name")
                        .validator(.required)

                    ImagePicker($selectedImages, existingImages: $existingImages, maxSelectionCount: 5)
                        .validator(AtLeastValidator(value: 1, { "Must select at least \($0) image\($0 == 1 ? "" : "s")" }))

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
                        .validator([
                            AnyValidator(.required),
                            AnyValidator(AtMostValidator(value: date1 ?? (date2 ?? Date.distantFuture), {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "MM/dd/yyyy"
                                return "Must be no later than \(formatter.string(from: $0))"
                            }))
                        ])

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
                        $price,
                        title: "Price",
                        format: .currency(code: "USD").presentation(.narrow)
                    )
                    .validator(.required)

                    TagSelector(selection: $selectedAmenities, tags: $amenities, customisable: .customisable(tagFromString: { $0}), title: "Amenities")
                        .validator(.required)

                    ComponentWrapper {
                        Button(action: {
                            showValidationErrors = true
                        }) {
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
                .environment(\.showValidationErrors, showValidationErrors)
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
