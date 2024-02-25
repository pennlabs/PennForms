//
//  ImagePicker.swift
//
//
//  Created by Christina Qiu on 2/23/24.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    
    @State var maxSelection: [PhotosPickerItem] = []
    @State var selectedImages: [UIImage] = []
    @State var maxSelectionCount: Int = 5
    
    var body: some View {
        VStack {
            PhotosPicker(selection: $maxSelection,
                         maxSelectionCount: maxSelectionCount,
                         matching: .any(of: [.images, .not(.videos)])) {
                VStack{
                    Image(systemName: "photo.badge.plus")
                        .padding(3)
                    Text("Add Photos")
                }
                        .frame(width: 350, height: 200)
                        .background(Rectangle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                            .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/))
                        .foregroundColor(Color.gray)
                        .padding()
            }
            .onChange(of: maxSelection) { newValue in
                Task {
                    selectedImages = []
                    for value in newValue {
                        if let imageData = try? await
                            value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                            selectedImages.append(image)
                        }
                    }
                }
            }
            .padding(-25)
            
            if selectedImages.count > 0 {
                ScrollView(.horizontal) {
                    HStack {
                        if selectedImages.count < maxSelectionCount {
                            VStack{
                                Image(systemName: "photo.badge.plus")
                                    .padding(3)
                                Text("Add Photos")
                                    
                            }
                                    .frame(width: 120, height: 120)
                                    .background(Rectangle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [7]))
                                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/))
                                    .foregroundColor(Color.gray)
                                    .padding()
                        }
                        ForEach(selectedImages, id: \.self)
                        {img in Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Rectangle())
                                
                            
                        }
                        ForEach(0..., maxSelectionCount - 1 - selectedImages.count) {
                                Image(systemName: "photo.badge.plus")
                                    .padding(3)
                                    .frame(width: 120, height: 120)
                                    .background(Rectangle()
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                                        .cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/))
                                    .foregroundColor(Color.gray)
                                    .padding()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ImagePicker()
}
