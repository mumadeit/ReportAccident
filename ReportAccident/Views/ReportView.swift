import SwiftUI
import UIKit

struct ReportView: View {
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var accidentType = AccidentType.carAccident
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showImagePicker = false
    @State private var image: UIImage? = nil

    enum AccidentType: String, CaseIterable, Identifiable {
            case carAccident = "Car 🚗"
            case pedestrianAccident = "Pedestrian 🚶🏻"
            case bikeAccident = "Bike 🚲"

            var id: String { self.rawValue }
        }

    var inputsFilled: Bool {
        !fullName.isEmpty && !phoneNumber.isEmpty && image != nil
    }

    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        Picker("Accident Type", selection: $accidentType) {
                            ForEach(AccidentType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        // Label and TextField for Full Name
                            Label("Your Full Name", systemImage: "person") // Optional: Add an icon with systemImage
                                .font(.headline) // Optional: Style the label
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()

                            // Label and TextField for Phone Number
                            Label("Your Phone Number", systemImage: "phone") // Optional: Add an icon with systemImage
                                .font(.headline) // Optional: Style the label
                            TextField("Enter your phone number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                        Button("Upload Image") {
                            showImagePicker = true
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .padding()
                        }

                        Button("Report Accident", action: reportAccident)
                            .buttonStyle(PrimaryButtonStyle())
                            .disabled(!inputsFilled)
                    }
                    .padding()
                    .navigationTitle("🚨 Report Accidents")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .sheet(isPresented: $showImagePicker, content: {
                    ImagePicker(selectedImage: $image)
                })
            }
        }
    
    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.white)
                .padding()
                .background(Color.red.cornerRadius(8))
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }

    func reportAccident() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/reports/new") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()

        let params = ["name": fullName, "phone": phoneNumber, "accident_type": accidentType.rawValue]
        for (key, value) in params {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        if let imageData = image?.jpegData(compressionQuality: 0.5) {
            httpBody.append(convertFileData(fieldName: "image",
                                            fileName: "accident.jpg",
                                            mimeType: "image/jpeg",
                                            fileData: imageData,
                                            using: boundary))
        }

        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.alertMessage = "An error occurred: \(error.localizedDescription)"
                    self.showAlert = true
                } else if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let message = jsonResponse["message"] as? String {
                            self.alertMessage = message
                        } else {
                            self.alertMessage = "Unexpected response from the server"
                        }
                    } catch {
                        self.alertMessage = "Failed to decode JSON response: \(error.localizedDescription)"
                    }
                    self.showAlert = true
                }
                self.isLoading = false
            }
        }
        task.resume()
        isLoading = true
    }

}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}

func convertFormField(named name: String, value: String, using boundary: String) -> String {
    var fieldString = "--\(boundary)\r\n"
    fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n"
    fieldString += "\(value)\r\n"
    return fieldString
}

func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
    let data = NSMutableData()
    data.appendString("--\(boundary)\r\n")
    data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
    data.appendString("Content-Type: \(mimeType)\r\n\r\n")
    data.append(fileData)
    data.appendString("\r\n")
    return data as Data
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView()
    }
}
