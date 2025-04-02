//
//  ImagePicker.swift
//
//
//  Created by Christina Qiu on 2/23/24.
//

import SwiftUI
import PhotosUI

public struct ImagePicker: FormComponent {
    @Environment(\.validator) var validator
    @Environment(\.showValidationErrors) var showValidationErrors
    @State var selection: [PhotosPickerItem]
    @Binding var selectedImages: [UIImage]
    @Binding var existingImages: [String]
    let maxSelectionCount: Int
    
    public init(_ selectedImages: Binding<[UIImage]>, existingImages: Binding<[String]>? = nil as Binding<[String]>?, maxSelectionCount: Int = 5) {
        self.selection = []
        self._selectedImages = selectedImages
        if let existingImagesBinding = existingImages {
            self._existingImages = existingImagesBinding
        } else {
            self._existingImages = State(initialValue: []).projectedValue
        }
        self.maxSelectionCount = maxSelectionCount
        self._validator = Environment(\.validator)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if existingImages.count > 0 {
                // if there are existing images in the database it displays the first one in the big photo frame
                AsyncImage(
                    url: URL(string: existingImages[0]),
                    content: { image in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 0.5))
                                .frame(width: 350, height: 200)
                            
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .allowsHitTesting(false)
                                
                        }
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
            } else if selectedImages.count > 0 {
                // else if there are selected images it displays the first one in the big photo frame
                ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(style: StrokeStyle(lineWidth: 0.5))
                                .frame(width: 350, height: 200)
                            
                    Image(uiImage: selectedImages[0])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                                .allowsHitTesting(false)
                                
                        
                    }
            } else {
                // else it displays the red "Add Photos" in the big photo frame
                PhotosPicker(selection: $selection,
                             maxSelectionCount: maxSelectionCount - existingImages.count,
                             matching: .any(of: [.images, .not(.videos)])) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                        Text("Add Photos")
                    }
                    .frame(width: 350, height: 200)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7])))
                    .foregroundColor(!showValidationErrors || validator.isValid(selectedImages.count + existingImages.count) ? Color.secondary : Color.red)
                }
                             .onChange(of: selection) { newSelection in
                                 Task {
                                     selectedImages.removeAll()
                                     for item in newSelection {
                                         if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                             selectedImages.append(image)
                                         }
                                     }
                                 }
                             }
            }
            
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(Array(existingImages.enumerated()), id: \.offset) { index, image in
                        if index != 0 {
                            // if there are existing images in database, the first one would have been placed in the big photo frame in the previous if statement, Thus we start displaying them from index 1
                            ForEach(existingImages, id: \.self) { url in
                                AsyncImage(
                                    url: URL(string: url),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .badge(imageStr: "xmark", badgeColor: Color(uiColor: .systemGray3), textColor: Color(uiColor: .systemGray), action: {
                                                withAnimation {
                                                    existingImages.removeAll(where: { $0 == url })
                                                }
                                            })
                                            .frame(width: 120, height: 120)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                                )
                            }
                        }
                    }
                    if (existingImages.count == 0 && selectedImages.count-1 > 0) || selectedImages.count > 0  {
                        // if there were no existing images and there are a number of selected images, then this displays the rest of the selected images from index 1. else if there were existing images then the first big photo frame is already filled and we start the selected images at count 0.
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            if index != 0 {
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
                    if selectedImages.count + existingImages.count < maxSelectionCount {
                        // if there are still spaces left for images to be added, we show the add image small icon boxes
                        ForEach(0..<(maxSelectionCount - selectedImages.count - existingImages.count), id: \.self) { _ in
                            PhotosPicker(selection: $selection,
                                         maxSelectionCount: maxSelectionCount - existingImages.count,
                                         matching: .any(of: [.images, .not(.videos)])) {
 
                                    Image(systemName: "photo.badge.plus")
                                .frame(width: 120, height: 120)
                                .background(RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1)))
                                .foregroundColor(Color.secondary)
                            }
                                         .onChange(of: selection) { newSelection in
                                             Task {
                                                 for item in newSelection {
                                                     if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                                                         selectedImages.append(image)
                                                     }
                                                 }
                                             }
                                         }
                        }
                    }
                }
            }
            
            if showValidationErrors, !validator.isValid(selectedImages.count + existingImages.count), let validatorMessage = validator.message {
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

#Preview {
    @State var selectedImages: [UIImage] = []
    @State var existingImages: [String] = []
    return ImagePicker($selectedImages, existingImages: $existingImages, maxSelectionCount: 5)
        .validator(AtLeastValidator(value: 1, { "Must select at least \($0) image\($0 == 1 ? "" : "s")" }))
}
