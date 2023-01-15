//
//  ContentView.swift
//  lab1-buttons
//
//  Created by Victor Șaptefrați on 06.01.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isShown: Bool = false
    @State private var image: Image = Image(systemName: "")
    
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    @State private var textFieldValue = ""
    @State private var frontCameraSelected = true
    @State private var rearCameraSelected = false

    let notificationCenter = UNUserNotificationCenter.current()
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Enter keywords", text: $textFieldValue)
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding()
                        .border(Color.gray, width: 1)
                    
                    Button(action: {
                        self.openBrowser()
                    }) {
                        Text("Google search")
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                    .border(Color.gray, width: 1)
                }
                .padding()
                
                HStack {
                    RadioButton(text: "Front camera", isSelected: $frontCameraSelected, action: {
                        self.frontCameraSelected = true
                        self.rearCameraSelected = false
                    })
                    RadioButton(text: "Rear camera", isSelected: $rearCameraSelected, action: {
                        self.frontCameraSelected = false
                        self.rearCameraSelected = true
                    })
                }
            
                HStack {
                    Button(action: {
                        self.isShown = true
                    }, label: {
                        Text("Take Photo")
                    })
                }
                .padding(0.2)
                
                HStack {
                    Button(action: {
                        self.showPushNotification()
                    }) {
                        Text("Push notification")
                    }
                }
                .padding()
            }
            
            image.resizable().frame(width: 150, height: 200)
        }
        .sheet(isPresented: $isShown, onDismiss: {
            self.isShown = false
        }, content: {
            ImagePicker(isShown: self.$isShown, image: self.$image, isRear: self.$rearCameraSelected)
        })
        .padding()
    }
    
    func showPushNotification() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if error == nil {
                if success {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Push Notification"
                    content.body = "This is a push notification"

                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

                    let request = UNNotificationRequest(identifier: "pushNotification", content: content, trigger: trigger)

                    notificationCenter.add(request)
                }
            } else {
            }
        }
        
        
    }
    
    func openBrowser() {
        guard let keyword = textFieldValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://www.google.com/search?q=\(keyword)"
        guard let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

struct RadioButton: View {
    let text: String
    @Binding var isSelected: Bool
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            self.isSelected = true
            self.action?()
        }) {
            HStack {
                Image(systemName: isSelected ? "circle.fill" : "circle")
                    .foregroundColor(.accentColor)
                Text(text)
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: Image
    @Binding var isRear: Bool
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        
        if (isRear) {
            picker.cameraDevice = .rear
        } else {
            picker.cameraDevice = .front
        }
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShown: $isShown, image: $image)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var isShown: Bool
        @Binding var image: Image
        
        init(isShown: Binding<Bool>, image: Binding<Image>) {
            _isShown = isShown
            _image = image
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            image = Image(uiImage: uiImage)
            isShown = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isShown = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
