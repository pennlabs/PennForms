//
//  ImagePicker.swift
//
//
//  Created by Jordan Hochman on 4/25/25.
//

import SwiftUI
import PhotosUI

public enum CustomImage: Equatable {
    case existing(String) // For existing images we have a URL to
    case selected(UIImage, Int?) // For images selected by the PhotosPicker, second argument is id (it's optional in case ImagePicker is instantiated with some UIImages of unknown origin
    case loading(Int) // For images selected by the PhotosPicker but that are still loading (none must exist for form validity)

    var isExisting: Bool {
        if case .existing = self { return true }
        return false
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var id: Int? {
        switch self {
        case .existing:
            return nil
        case .selected(_, let id):
            return id
        case .loading(let id):
            return id
        }
    }
}

struct LargeCustomImageView: View {
    let image: CustomImage

    var body: some View {
        switch image {
        case .existing(let urlString):
            AsyncImage(
                url: URL(string: urlString),
                content: { image in
                    // TODO: Fix image size bug from before
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(style: StrokeStyle(lineWidth: 0.5))
                            .frame(width: 350, height: 200)

                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 350, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                },
                placeholder: {
                    ProgressView()
                }
            )
        case .selected(let image, _):
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 0.5))
                    .frame(width: 350, height: 200)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 350, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        case .loading:
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.tertiary)
                    .frame(width: 350, height: 200)

                ProgressView()
            }
        }
    }
}

struct SmallCustomImageView: View {
    let image: CustomImage
    let deleteAction: ((String) -> Void)?

    init(image: CustomImage, deleteAction: ((String) -> Void)? = nil) {
        self.image = image
        self.deleteAction = deleteAction
    }

    var body: some View {
        switch image {
        case .existing(let urlString):
            AsyncImage(
                url: URL(string: urlString),
                content: { image in
                    if let deleteAction {
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .badge(imageStr: "xmark", badgeColor: Color(uiColor: .systemGray3), textColor: Color(uiColor: .systemGray), action: {
                                deleteAction(urlString)
                            })
                            .frame(width: 120, height: 120)
                    } else {
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                    }
                },
                placeholder: {
                    ProgressView()
                }
            )
        case .selected(let image, _):
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 0.5))
                    .frame(width: 120, height: 120)

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        case .loading:
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.tertiary)
                    .frame(width: 120, height: 120)

                ProgressView()
            }
        }
    }
}

public struct ImagePicker: FormComponent {
    @Environment(\.validator) var validator
    @Environment(\.showValidationErrors) var showValidationErrors
    @State var selection: [PhotosPickerItem]
    @Binding var images: [CustomImage]
    let maxSelectionCount: Int
    @State var draggedIndex: Int?

    public init(_ images: Binding<[CustomImage]>, maxSelectionCount: Int = 5) {
        // TODO: Make work with original binding
        self.selection = []
        self._images = images
        self.maxSelectionCount = maxSelectionCount
        self._validator = Environment(\.validator)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            PhotosPicker(selection: $selection,
                         maxSelectionCount: maxSelectionCount - images.count(where: { $0.isExisting }),
                         matching: .any(of: [.images, .not(.videos)])) {
                if images.count > 0 {
                    ZStack {
                        LargeCustomImageView(image: images[0])

                        if draggedIndex == 0 {
                            Color(.blue)
                                .opacity(0.25)
                                .frame(width: 350, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .draggable(0) {
                        SmallCustomImageView(image: images[0])
                    }
                    .dropDestination(for: Int.self) { items, _ in
                        guard let srcIndex = items.first, srcIndex > 0, srcIndex < images.count else {
                            return false
                        }
                        withAnimation {
                            images.swapAt(srcIndex, 0)
                        }
                        return true
                    } isTargeted: { isTargeted in
                        draggedIndex = isTargeted ? 0 : nil
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                        Text("Add Photos")
                    }
                    .frame(width: 350, height: 200)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7])))
                    .foregroundColor(!showValidationErrors || validator.isValid(images.count) ? Color.secondary : Color.red)
                    .contentShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .buttonStyle(.plain)

            if maxSelectionCount > 1 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        if images.count > 0 {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                if index != 0 {
                                    PhotosPicker(selection: $selection,
                                                 maxSelectionCount: maxSelectionCount - images.count(where: { $0.isExisting }),
                                                 matching: .any(of: [.images, .not(.videos)])) {
                                        ZStack {
                                            SmallCustomImageView(image: image, deleteAction: { urlString in
                                                withAnimation {
                                                    images.removeAll { $0 == .existing(urlString) }
                                                }
                                            })

                                            if index == draggedIndex {
                                                Color(.blue)
                                                    .opacity(0.25)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .draggable(index) {
                                        SmallCustomImageView(image: image)
                                    }
                                    .dropDestination(for: Int.self) { items, _ in
                                        guard let srcIndex = items.first, srcIndex != index, srcIndex >= 0, srcIndex < images.count else {
                                            return false
                                        }
                                        withAnimation {
                                            images.swapAt(srcIndex, index)
                                        }
                                        return true
                                    } isTargeted: { isTargeted in
                                        draggedIndex = isTargeted ? index : nil
                                    }
                                }
                            }
                        }

                        let numTakenSlots = max(images.count - 1, 0)
                        if numTakenSlots < maxSelectionCount - 1 {
                            ForEach(0..<(maxSelectionCount - 1 - numTakenSlots), id: \.self) { _ in
                                PhotosPicker(selection: $selection,
                                             maxSelectionCount: maxSelectionCount - images.count(where: { $0.isExisting }),
                                             matching: .any(of: [.images, .not(.videos)])) {
                                    Image(systemName: "photo.badge.plus")
                                        .frame(width: 120, height: 120)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1)))
                                        .foregroundColor(Color.secondary)
                                        .contentShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                                .dropDestination(for: Int.self) { items, _ in
                                    guard let srcIndex = items.first, srcIndex >= 0, srcIndex < images.count else {
                                        return false
                                    }
                                    withAnimation {
                                        let image = images.remove(at: srcIndex)
                                        images.append(image)
                                    }
                                    return true
                                } isTargeted: { _ in
                                    draggedIndex = nil
                                }
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            if showValidationErrors {
                if !validator.isValid(images.count), let validatorMessage = validator.message(images.count) {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle")
                        Text(validatorMessage)
                    }
                    .foregroundColor(.red)
                    .preference(key: ValidPreferenceKey.self, value: false)
                } else if images.count(where: { $0.isLoading }) > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.circle")
                        Text("Please wait for images to finish loading!")
                    }
                    .foregroundColor(.red)
                    .preference(key: ValidPreferenceKey.self, value: false)
                }
            } else {
                Text("Add up to \(maxSelectionCount) photo\(maxSelectionCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
        }
        .onChange(of: selection) { _ in
            Task { await handleNewSelection(selection) }
        }
    }

    @MainActor
    func handleNewSelection(_ newSelection: [PhotosPickerItem]) async {
        let itemsById = Dictionary(uniqueKeysWithValues: newSelection.map { ($0.hashValue, $0) })
        let newIds = Set(itemsById.keys)

        let existingIds = Set(images.compactMap(\.id))
        let idsToLoad = newIds.subtracting(existingIds)

        images = images.filter { img in
            switch img {
            case .existing:
                return true
            case .selected(_, let id):
                // keep if in newSelection, or if it had no id
                return id.map { newIds.contains($0) } ?? true
            case .loading(let id):
                return newIds.contains(id)
            }
        } + idsToLoad.map { .loading($0) }

        let loadedImages: [Int: UIImage] = await withTaskGroup(of: (Int, UIImage)?.self) { group in
            for id in idsToLoad {
                if let item = itemsById[id] {
                    group.addTask {
                        guard let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else {
                            return nil
                        }
                        return (id, img)
                    }
                }
            }

            var dict: [Int: UIImage] = [:]
            for await result in group {
                if let (id, img) = result {
                    dict[id] = img
                }
            }
            return dict
        }

        images = images.compactMap { img in
            switch img {
            case .existing, .selected:
                return img
            case .loading(let id):
                return loadedImages[id].map { .selected($0, id) }
            }
        }
    }
}

struct CustomBadgeModifier: ViewModifier {
    let text: String?
    let imageStr: String?
    let badgeColor: Color
    let textColor: Color
    let enabled: Bool
    let action: (() -> Void)?

    init(text: String? = nil, imageStr: String? = nil, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) {
        self.text = text
        self.imageStr = imageStr
        self.badgeColor = badgeColor
        self.textColor = textColor
        self.enabled = enabled
        self.action = action
    }

    @ViewBuilder
    func badgeView() -> some View {
        ZStack {
            Circle()
                .fill(badgeColor)
                .frame(width: 20, height: 20)

            if let text = text {
                Text(text)
                    .foregroundColor(textColor)
                    .font(.system(size: 12))
            } else if let imageStr = imageStr {
                Image(systemName: imageStr)
                    .resizable()
                    .foregroundColor(textColor)
                    .frame(width: 10, height: 10)
            }
        }
        .offset(x: 10, y: -10)
    }

    func body(content: Content) -> some View {
        if enabled {
            if let action = action {
                content
                    .overlay(
                        Button(action: action) {
                            badgeView()
                        },
                        alignment: .topTrailing
                    )
            } else {
                content
                    .overlay(
                        badgeView(),
                        alignment: .topTrailing
                    )
            }
        } else {
            content
        }
    }
}

public extension View {
    func badge(_ text: String, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        self.modifier(CustomBadgeModifier(text: text, badgeColor: badgeColor, textColor: textColor, enabled: enabled, action: action))
    }

    func badge(imageStr: String, badgeColor: Color = .red, textColor: Color = .white, enabled: Bool = true, action: (() -> Void)? = nil) -> some View {
        self.modifier(CustomBadgeModifier(imageStr: imageStr, badgeColor: badgeColor, textColor: textColor, enabled: enabled, action: action))
    }
}

extension Int: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}

#Preview {
    @State var images: [CustomImage] = []
    return ImagePicker($images, maxSelectionCount: 5)
        .validator(AtLeastValidator(value: 1, { "Must select at least \($0) image\($0 == 1 ? "" : "s")" }))
}
