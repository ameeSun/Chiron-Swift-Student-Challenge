//
//  TracingGameView.swift
//  Chiron
//
//  Created by ak on 2/15/25.
//

import SwiftUI
import PencilKit
import CoreImage
import PhotosUI

struct TracingGameView: View {
    @State private var outlineImage: UIImage?
    private var canvasView = PKCanvasView()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data? = nil
    @State private var image: Image?
    @Environment(\.undoManager) private var undoManager
    //    @State private var undoStack: [PKDrawing] = []
    
    // lets the user clear the canvas (does not remove the photo)
    func clear() {
        canvasView.drawing = PKDrawing()
    }
    
    // lets the user undo their last drawing stroke
    //    func undo(){
    //        guard !undoStack.isEmpty else { return }
    //        undoStack.removeLast()
    //        canvasView.drawing = undoStack.last ?? PKDrawing()
    //    }
    
    var body: some View {
        VStack() {
            Spacer(minLength: 10)
            // "click for instructions" pop-up
            ExtractView(fieldText: "Click for Instructions",fieldInfo: """
                1. Pick a photo from your camera roll to use as the tracing background.
                2. Use your finger or stylus to outline and draw over the image.
                3. Made a mistake? Use the undo/redo buttons to fix your lines.
                4. Save your traced drawing to your camera roll to track progress!
                """)
            .padding()
            ZStack() {
                image?
                    .resizable()
                    .scaledToFit()
                //                MyCanvas2(canvasView: $canvasView, undoStack: $undoStack)
                MyCanvas(canvasView: canvasView)
            }.task(id: selectedPhoto) {
                selectedImageData = try? await selectedPhoto?.loadTransferable(type: Data.self)
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    image=Image(uiImage: applyEdgeDetection(to: uiImage)!)
                }
            }
            VStack{
                HStack{
                    // Pick photo button
                    PhotosPicker(selection: $selectedPhoto,
                                 matching: .images) {
                        Text("Pick Photo")
                            .padding(.horizontal)
                            .font(.headline)
                            .foregroundColor(.black)
                    }.padding().background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.pink, lineWidth: 1)
                    )
                    
                    
                    // Clear canvas button
                    Button(action: clear
                    ) {
                        Text("Redraw")
                            .padding(.horizontal)
                            .font(.headline)
                            .foregroundColor(.black)
                    }.padding().background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.pink, lineWidth: 1)
                    )
                }
                .padding()
                HStack{
                    Button("Undo") {
                        undoManager?.undo()
                    }.foregroundColor(.black)
                        .padding().background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.pink, lineWidth: 1)
                        )
                    Button("Redo") {
                        undoManager?.redo()
                    }.foregroundColor(.black)
                        .padding().background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.pink, lineWidth: 1)
                        )
                }
            }
        }
    }
    
    
    func applyEdgeDetection(to image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let filter_overlay = CIFilter(name: "CILineOverlay")
        print(filter_overlay!.inputKeys)
        filter_overlay?.setValue(ciImage, forKey: kCIInputImageKey)
        filter_overlay?.setValue(0.07, forKey: "inputNRNoiseLevel")
        filter_overlay?.setValue(0.71, forKey: "inputNRSharpness")
        filter_overlay?.setValue(1, forKey: "inputEdgeIntensity")
        filter_overlay?.setValue(0.1, forKey: "inputThreshold")
        filter_overlay?.setValue(50, forKey: kCIInputContrastKey)
        guard let outputImage_overlay = filter_overlay?.outputImage else { return nil }
        guard let outputImage = filter_overlay?.outputImage else { return nil }
        let context = CIContext()
        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    
}





//func applyEdgeDetection(to image: UIImage) -> UIImage? {
//    guard let ciImage = CIImage(image: image) else { return nil }
//
//    let grayscaleFilter = CIFilter(name: "CIPhotoEffectMono") // Convert to grayscale
//    grayscaleFilter?.setValue(ciImage, forKey: kCIInputImageKey)
//
//    let edgeFilter = CIFilter(name: "CILaplacian") // Laplacian edge detection
//    edgeFilter?.setValue(grayscaleFilter?.outputImage, forKey: kCIInputImageKey)
//
//    guard let outputImage = edgeFilter?.outputImage else { return nil }
//
//    let context = CIContext()
//    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//        return UIImage(cgImage: cgImage)
//    }
//
//    return nil
//}



#Preview {
    TracingGameView()
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {
        
        @Binding
        private var presentationMode: PresentationMode
        private let sourceType: UIImagePickerController.SourceType
        private let onImagePicked: (UIImage) -> Void
        
        init(presentationMode: Binding<PresentationMode>,
             sourceType: UIImagePickerController.SourceType,
             onImagePicked: @escaping (UIImage) -> Void) {
            _presentationMode = presentationMode
            self.sourceType = sourceType
            self.onImagePicked = onImagePicked
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            onImagePicked(uiImage)
            presentationMode.dismiss()
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: presentationMode,
                           sourceType: sourceType,
                           onImagePicked: onImagePicked)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
}

//struct MyCanvas2: UIViewRepresentable {
//    @Binding var canvasView: PKCanvasView
//    @Binding var undoStack: [PKDrawing]
//
//    func makeUIView(context: Context) -> PKCanvasView {
//        canvasView.drawingPolicy = .anyInput
//        canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
//        canvasView.delegate = context.coordinator
//        return canvasView
//    }
//
//    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, PKCanvasViewDelegate {
//        var parent: MyCanvas2
//
//        init(_ parent: MyCanvas2) {
//            self.parent = parent
//        }
//
//        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//            parent.undoStack.append(canvasView.drawing) // Save each stroke
//        }
//    }
//}
