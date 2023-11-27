import OrderedCollections
import SwiftUI

public struct TagSelector<Tag: Hashable>: FormComponent {
    @Binding public var selection: OrderedSet<Tag>
    @Binding public var tags: OrderedSet<Tag>
    let toString: (Tag) -> String
    let customisable: Customisable
    let title: String?
    
    @Environment(\.validator) var validator
    @Environment(\.colorScheme) var colorScheme
    
    enum Customisable {
        case notCustomisable
        case customisable(tagFromString: (String) -> Tag)
    }
    
    init(selection: Binding<OrderedSet<Tag>>, tags: Binding<OrderedSet<Tag>>, toString: @escaping (Tag) -> String, _ customisable: Customisable = .notCustomisable, title: String? = nil) {
        self._selection = selection
        self._tags = tags
        self.toString = toString
        self.customisable = customisable
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    init(selection: Binding<OrderedSet<Tag>>, tags: Binding<OrderedSet<Tag>>, customisable: Customisable = .notCustomisable, title: String? = nil) where Tag: RawRepresentable<String> {
        self._selection = selection
        self._tags = tags
        self.toString = { $0.rawValue }
        self.customisable = customisable
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    init(selection: Binding<OrderedSet<Tag>>, tags: Binding<OrderedSet<Tag>>, customisable: Customisable = .notCustomisable, title: String? = nil) where Tag: LosslessStringConvertible {
        self._selection = selection
        self._tags = tags
        self.toString = { $0.description }
        self.customisable = customisable
        self.title = title
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title)
                    .bold()
            }
            TagGrid(
                availableWidth: UIScreen.main.bounds.width,
                data: $tags,
                customisable: customisable,
                spacing: 10,
                alignment: .leading) { tag in
                    Button(action: { selection.contains(tag) ? ignore(selection.remove(tag)) : ignore(selection.append(tag)) }) {
                        HStack {
                            Image(systemName: selection.contains(tag) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selection.contains(tag) ? .blue : .primary)
                            Text(toString(tag))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(in: Capsule())
                        .backgroundStyle(selection.contains(tag) ? .blue.opacity(colorScheme == .light ? 0.1 : 0.2) : .secondary.opacity(colorScheme == .light ? 0.1 : 0.2))
                    }
                    .buttonStyle(.plain)
                }
        }
    }
}

struct TagGrid<Tag: Hashable, Content: View>: View {
    let availableWidth: CGFloat
    @Binding var data: OrderedSet<Tag>
    let customisable: TagSelector<Tag>.Customisable
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Tag) -> Content
    @State var elementsSize: [Tag: CGSize] = [:]
    
    @State var showTagCreator = false
    @State var newTag = ""
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                        //              .readSize { size in
                        //                elementsSize[element] = size
                        //              }
                    }
                }
            }
            
            if case let .customisable(tagFromString) = customisable {
                Button(action: { showTagCreator = true }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add your own")
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                }
                .buttonStyle(.plain)
                .background { Capsule().strokeBorder() }

                .sheet(isPresented: $showTagCreator) {
                    VStack {
                        Text("Create your own")
                            .bold()
                            .font(.title)
                        TextLineField($newTag, placeholder: "Name")
                            .padding()
                        Button(action: { showTagCreator = false; newTag.isEmpty ? () : ignore(data.append(tagFromString(newTag)))}) {
                            Text("Add")
                                .font(.title3)
                                .bold()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                        .background(in: Capsule())
                        .foregroundStyle(.white)
                        .backgroundStyle(.blue)
                    }
                    .presentationDetents([.fraction(0.33), .medium])
                }
            }
        }
    }
    
    func computeRows() -> [[Tag]] {
        var rows: [[Tag]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

private func ignore<T>(_ v: T) { () }
