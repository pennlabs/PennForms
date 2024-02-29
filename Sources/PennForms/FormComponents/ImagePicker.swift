//
//  ImagePicker.swift
//
//
//  Created by Christina Qiu on 2/23/24.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @State var selection: [PhotosPickerItem] = []
    @State var selectedImages: [Image] = []
    @State var maxSelectionCount: Int = 5
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PhotosPicker(selection: $selection,
                         maxSelectionCount: maxSelectionCount,
                         matching: .any(of: [.images, .not(.videos)])) {
                VStack(spacing: 8) {
                    Image(systemName: "photo.badge.plus")
                    Text("Add Photos")
                }
                .frame(width: 350, height: 200)
                .background(RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7])))
                .foregroundColor(Color.secondary)
            }
            .onChange(of: selection) { newSelection in
                Task {
                    selectedImages.removeAll()
                    for item in newSelection {
                        if let image = try? await item.loadTransferable(type: Image.self) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
            
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    if selectedImages.count > 0 {
                        ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                        }
                    }
                    if selectedImages.count < maxSelectionCount {
                        ForEach(0..<(maxSelectionCount - selectedImages.count), id: \.self) { _ in
                            Image(systemName: "photo.badge.plus")
                                .frame(width: 120, height: 120)
                                .background(RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 0.5)))
                                .foregroundColor(Color.secondary)
                        }
                    }
                }
            }
            Text("Add up to \(maxSelectionCount) photo\(maxSelectionCount == 1 ? "" : "s")")
                .font(.subheadline)
                .foregroundColor(Color.secondary)
        }
    }
}

#Preview {
    ImagePicker()
}
