import SwiftUI

#if canImport(UIKit)
import UIKit

struct VideoCapturePicker: UIViewControllerRepresentable {
    enum Source {
        case camera
        case library
    }

    let source: Source
    let onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.mediaTypes = ["public.movie"]
        controller.videoQuality = .typeMedium
        controller.sourceType = source == .camera && UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.mediaURL] as? URL {
                onPick(url)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#else

struct VideoCapturePicker: View {
    enum Source {
        case camera
        case library
    }

    let source: Source
    let onPick: (URL) -> Void

    var body: some View {
        Text("Video picker requires UIKit and a full iOS SDK.")
            .padding()
    }
}

#endif
