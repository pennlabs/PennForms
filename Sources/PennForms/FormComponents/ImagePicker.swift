//
//  ImagePicker.swift
//
//
//  Created by Christina Qiu on 2/23/24.
//

import SwiftUI
import PhotosUI

public enum CustomImage: Equatable {
    case existing(String)
    case selected(UIImage)
}

struct LargeCustomImageView: View {
    let image: CustomImage

    var body: some View {
        switch image {
        case .existing(let urlString):
            AsyncImage(
                url: URL(string: urlString),
                content: { image in
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
        case .selected(let image):
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
        case .selected(let image):
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
        self.selection = []
        self._images = images
        self.maxSelectionCount = maxSelectionCount
        self._validator = Environment(\.validator)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if images.count > 0 {
                LargeCustomImageView(image: images[0])
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
                // TODO: still let button select thingies
            } else {
                PhotosPicker(selection: $selection,
                             maxSelectionCount: maxSelectionCount - images.count,
                             matching: .any(of: [.images, .not(.videos)])) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                        Text("Add Photos")
                    }
                    .frame(width: 350, height: 200)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7])))
                    .foregroundColor(!showValidationErrors || validator.isValid(images.count) ? Color.secondary : Color.red)
                }
            }

            if maxSelectionCount > 1 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        if images.count > 0 {
                            ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                                if index != 0 {
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
                                             maxSelectionCount: maxSelectionCount - images.count,
                                             matching: .any(of: [.images, .not(.videos)])) {
                                    Image(systemName: "photo.badge.plus")
                                        .frame(width: 120, height: 120)
                                        .background(RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1)))
                                        .foregroundColor(Color.secondary)
                                }
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

            if showValidationErrors, !validator.isValid(images.count), let validatorMessage = validator.message(images.count) {
                HStack(spacing: 5) {
                    Image(systemName: "exclamationmark.circle")
                    Text(validatorMessage)
                }
                .foregroundColor(.red)
                .preference(key: ValidPreferenceKey.self, value: false)
            } else {
                Text("Add up to \(maxSelectionCount) photo\(maxSelectionCount == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(Color.secondary)
            }
        }
        .onChange(of: selection) {
            Task { await handleNewSelection(selection) }
            // TODO: DOES THIS NEED TO BE onchange?
        }
    }

    func handleNewSelection(_ newSelection: [PhotosPickerItem]) async {
        // TODO: This takes too long, need user status
        let loadedUIImages: [UIImage] = await withTaskGroup(of: UIImage?.self) { group in
            for item in newSelection {
                group.addTask {
                    guard let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else {
                        return nil
                    }
                    return img
                }
            }

            var loaded: [UIImage] = []
            for await maybeImg in group {
                if let img = maybeImg {
                    loaded.append(img)
                }
            }
            return loaded
        }

        await MainActor.run {
            let selectedIndices = images.enumerated()
                .compactMap { (idx, img) -> Int? in
                    if case .selected = img { return idx }
                    return nil
                }

            var updated = images
            for (i, newImage) in loadedUIImages.enumerated() {
                if i < selectedIndices.count {
                    updated[selectedIndices[i]] = .selected(newImage)
                } else {
                    updated.append(.selected(newImage))
                }
            }

            if loadedUIImages.count < selectedIndices.count {
                let toRemove = selectedIndices[loadedUIImages.count...]
                    .sorted(by: >) // sort descending so removal works fine
                for idx in toRemove {
                    updated.remove(at: idx)
                }
            }

            images = updated
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
