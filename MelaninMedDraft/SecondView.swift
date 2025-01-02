import SwiftUI
import UIKit
import CoreML
import FirebaseAuth
import Firebase
import FirebaseFirestore
let firestoreManager = AppDelegate()
struct ConditionsListView: View {
    let conditions: [String]
    @Binding var showConditions: Bool
    
    var body: some View {
          NavigationView {
              VStack {
                  Text("App is 99% accurate in diagnosing these conditions. This is not a comprehensive list of all abnormalities.\n")
                      .font(.subheadline)
                      .foregroundColor(.black)
                      .padding(.horizontal, 15)
                      .padding(.bottom, 3)
                  List(conditions, id: \.self) { condition in
                      Text(condition)
                  }
              }
              .navigationTitle("Trained Conditions")
              .toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                      Button(action: {
                          showConditions = false
                      }) {
                          Image(systemName: "xmark")
                              .foregroundColor(.black)
                      }
                  }
              }
              .background(Color(hex: colorPalette[0]))
              .edgesIgnoringSafeArea(.bottom)
          }
      }
  }

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        var parent: ImagePicker
        init(parent: ImagePicker) {
            self.parent = parent
        }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
struct BodyImageView: View {
    @Binding var showImagePicker: Bool
    @Binding var selectedLocation: String?
    @Binding var showPopup: Bool
    
     let bodyAreas = [
        (label: "Torso", rect: CGRect(x: 140, y: 110, width: 80, height: 170)),
        (label: "Head/Shoulders", rect: CGRect(x: 100, y: 0, width: 170, height: 100)),
        (label: "Right Arm", rect: CGRect(x: 220, y: 90, width: 60, height: 220)),
        (label: "Left Arm", rect: CGRect(x: 80, y: 90, width: 60, height: 220)),
        (label: "Right Leg", rect: CGRect(x: 180, y: 250, width: 50, height: 260)),
        (label: "Left Leg", rect: CGRect(x: 100, y: 250, width: 50, height: 260))
    ]
    
    var body: some View {
        VStack {
            ZStack {
                Image("body-outline")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300, maxHeight: 500)
                    .padding(.bottom, 5)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                let tapLocation = value.location
                                if let area = checkIfInsideOutlinedArea(location: tapLocation) {
                                    selectedLocation = area
                                }
                            }
                    )
                
                
                ForEach(bodyAreas, id: \.label) { area in
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: area.rect.width, height: area.rect.height)
                        .position(x: area.rect.midX, y: area.rect.midY)
                        .opacity(0)
                }
            }
            HStack {
                if let location = selectedLocation {
                    //Text("\n\n")
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: colorPalette[0]))
                            .frame(width: 230, height: 60)
                            .cornerRadius(10)
                        
                        Text("Selected: \(location)")
                            .foregroundColor(.black)
                            .padding(5)
                            .cornerRadius(5)
                    }
                } else {
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: colorPalette[0]))
                            .frame(width: 230, height: 60)
                            .cornerRadius(10)
                        
                        Text("Selected: ")
                            .foregroundColor(.black)
                            .padding(5)
                            .cornerRadius(5)
                    }
                    .cornerRadius(10)
                }
                
                Button(action: {
                        showPopup = true
                    }) {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .frame(width: 30, height: 24)
                            .padding()
                            .foregroundColor(.black)
                            .background(Color(hex: colorPalette[2]))
                            .cornerRadius(10)
                    }
                    
                    .sheet(isPresented: $showPopup) {
                        ZStack {
                            VStack(spacing: 20) {
                                
                                Text("Take a clear picture with the blemish **centered** and **in focus**. Keep the phone 90 degrees to the skin.")
                                    .font(.subheadline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.leading)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                
                                Text("If a **non-skin image** is submitted, the results are not applicable.")
                                    .font(.subheadline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                
                                
                                Button(action: {
                                    showPopup = false
                                    showImagePicker = true
                                }) {
                                    Image(systemName: "xmark")
                                        .padding()
                                        .foregroundColor(Color(hex: colorPalette[4]))
                                        .background(Color.white)
                                        .cornerRadius(10)
                                }
                            }
                            
                            .padding()
                            .background(Color(hex: colorPalette[4]))
                            .cornerRadius(20)
                            .shadow(radius: 15)
                            .frame(width: 320)
                        }
                    }
                   
                    if showImagePicker {
                        ImagePicker(selectedImage: .constant(nil))
                            .zIndex(1)
                    }
                }
            }
        }
                
    private func checkIfInsideOutlinedArea(location: CGPoint) -> String? {
        for area in bodyAreas {
            if area.rect.contains(location) {
                return area.label
            }
        }
        return nil
    }
}
struct SecondView: View {
    @State private var showImagePicker = false
    @State private var image: UIImage?
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var region = ""
    @State private var showForm = false
    @State private var predictionResult: String?
    @State private var diagResult: Int?
    @State private var diagResultString: String?
    @State private var documentID: String? = nil
    @State private var result: String?
    @State private var selectedLocation: String?
    @State private var showPopup = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    private let conditions = [
        "Abrasions Ulcerations and Physical Injuries"
,            "Abscess"
,           "Acne Cystic"
,          "Acquired Digital Fibrokeratoma"
,         "Acral Melanotic Macule"
,        "Acrochordon"
 ,       "Actinic Keratosis"
  ,      "Angioleiomyoma"
   ,     "Angioma"
    ,    "Arteriovenous Hemangioma"
     ,   "Atypical Spindle Cell Nevus of Reed"
      ,  "Basal Cell Carcinoma"
       , "Basal Cell Carcinoma Nodular"
        ,"Basal Cell Carcinoma Superficial"
,            "Benign Keratosis"
,           "Blastic Plasmacytoid Dendritic Cell Neoplasm"
,          "Blue Nevus"
,       "Cellular Neurothekeoma"
 ,       "Chondroid Syringoma"
  ,     "Clear Cell Acanthoma"
   ,     "Coccidioidomycosis"
    ,    "Condyloma Accuminatum"
     ,   "Dermatofibroma"
      ,  "Dermatomyositis"
       , "Dysplastic Nevus"
,            "Eccrine Poroma"
,           "Eczema Spongiotic Dermatitis"
,          "Epidermal Cyst"
,         "Epidermal Nevus"
,        "Fibrous Papule"
 ,       "Focal Acral Hyperkeratosis"
  ,      "Folliculitis"
   ,     "Foreign Body Granuloma"
    ,    "Glomangioma"
     ,   "Graft Vs Host Disease"
      ,  "Hematoma"
       , "Hyperpigmentation"
        ,"Inverted Follicular Keratosis"
,            "Kaposi Sarcoma"
,           "Keloid"
,          "Leukemia Cutis"
,         "Lichenoid Keratosis"
,        "Lipoma"
 ,       "Lymphocytic Infiltrations"
  ,      "Melanocytic Nevi"
   ,     "Melanoma"
    ,    "Melanoma Acral Lentiginous"
     ,  "Melanoma in Situ"
       , "Metastatic Carcinoma"
,            "Molluscum Contagiosum"
,           "Morphea"
,          "Mycosis Fungoides"
,         "Neurofibroma"
,        "Neuroma"
 ,       "Nevus Lipomatosus Superficialis"
  ,      "Nodular Melanoma (Nm)"
   ,     "Onychomycosis"
    ,    "Pigmented Spindle Cell Nevus of Reed"
     ,   "Prurigo Nodularis"
      ,  "Pyogenic Granuloma"
       , "Reactive Lymphoid Hyperplasia"
        ,"Scar"
,        "Sebaceous Carcinoma"
,            "Seborrheic Keratosis"
,           "Seborrheic Keratosis Irritated"
,          "Solar Lentigo"
,         "Squamous Cell Carcinoma"
,        "Squamous Cell Carcinoma in Situ"
 ,       "Squamous Cell Carcinoma Keratoacanthoma"
  ,      "Subcutaneous T Cell Lymphoma"
   ,     "Syringocystadenoma Papilliferum"
    ,    "Tinea Pedis"
     ,   "Trichilemmoma"
      ,  "Trichofolliculoma"
       , "Verruca Vulgaris"
,        "Verruciform Xanthoma"
 ,       "Wart"
  ,      "Xanthogranuloma"
        ]
     
    
    private let riskClassifier: RiskClassifier = {
        do {
            let configuration = MLModelConfiguration()
            return try RiskClassifier(configuration: configuration)
        } catch {
            fatalError("Couldn't load RiskClassifier model: \(error)")
        }
    }()
    private let diagnoser: Diagnoser = {
        do {
            let configuration = MLModelConfiguration()
            return try Diagnoser(configuration: configuration)
        } catch {
            fatalError("Couldn't load Diagnoser model: \(error)")
        }
    }()
    var body: some View {
        ScrollView {
            HStack {
                
                VStack {
                    if let image = image {
                       
                        
                    } else {
                        Text("\nTap the body part being scanned, then click the pink camera icon.\n")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                        BodyImageView(showImagePicker: $showImagePicker, selectedLocation: $selectedLocation, showPopup: $showPopup)
                    }
                    VStack {
                        if let result = predictionResult, let diagnosis = diagResultString {
                            ZStack {
                                VStack {
                                    HStack(spacing: 10) {
                                        ZStack {
                                            VStack {
                                                Text("Prediction:")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .padding(.top, 10)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(result)")
                                                    .font(.subheadline)
                                                    .padding()
                                                    .lineLimit(nil)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                
                                                Button(action: {
                                                       if result.lowercased() == "benign" {
                                                           showAlert(message: "Benign indicates that the condition is not cancerous.")
                                                       } else if result.lowercased() == "malignant" {
                                                           showAlert(message: "Malignant indicates that the condition is harmful and may be cancerous.")
                                                       }
                                                   }) {
                                                       Image(systemName: "questionmark.circle.fill")
                                                           .font(.title)
                                                           .foregroundColor(.white)
                                                   }
                                                   .padding(.top, 1)
                                            }
                                            .padding()
                                            .frame(width: 170, height: 200)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: colorPalette[0]).opacity(0.6),
                                                        Color(hex: colorPalette[1]).opacity(1.4)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(12)
                                            .shadow(radius: 2)
                                            .padding(.top, 40)
                                        }
                                        
                                        ZStack {
                                            VStack {
                                                Text("Diagnosis:")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .padding(.top, 10)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(diagnosis)")
                                                    .font(.subheadline)
                                                    .padding()
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(nil)
                                                    .foregroundColor(.white)
                                                
                                                Button(action: {
                                                       if diagnosis.lowercased() == "normal" {
                                                           showAlert(message: "You're most likely healthy.")
                                                       } else {
                                                           showAlert(message: "Learn more about your diagnosis by asking the MelaninMed Dermatologist in the Chat tab.")
                                                       }
                                                   }) {
                                                       Image(systemName: "questionmark.circle.fill")
                                                           .font(.title)
                                                           .foregroundColor(.white)
                                                   }
                                                  // .padding(.top, 5)
                                            }
                                            .padding()
                                            .frame(width: 170, height: 200)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: colorPalette[2]).opacity(0.8),
                                                        Color(hex: colorPalette[3]).opacity(1.3)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(12)
                                            .shadow(radius: 2)
                                            .padding(.top, 40)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, 10)
                                    
                                    HStack(spacing: 10) {
                                        VStack {
                                            ZStack {
                                                Text("This is not a substitute for medical advice. Please see a licensed physician for a further diagnosis.")
                                                    .multilineTextAlignment(.center)
                                                    .padding(.vertical, 15)
                                                    .font(.subheadline)
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 15)
                                            }
                                            .frame(width: 170, height: 250)
                                            .background(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: colorPalette[4]).opacity(0.64),
                                                        Color(hex: colorPalette[4]).opacity(1.6)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .cornerRadius(12)
                                        }
                                        VStack {
                                            ZStack {
                                                Image(uiImage: image!)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 170, height: 250)
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
                                    .padding(.bottom, 20)
                                    .padding()
                                        
                                    Button(action: {
                                        resetView()
                                    }) {
                                        Text("Scan Again")
                                            .padding(.horizontal, 30)
                                            .padding(.vertical, 10)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .background(Color(hex: colorPalette[5]))
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 5)
                                .background(Color.clear)
                                .cornerRadius(15)
                                
                            }
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(selectedImage: $image)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Learn More"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    .onChange(of: image) { oldValue, newImage in
                        if let image = newImage {
                            predictImage(image: image)
                        }
                    }
                }
            }
        }
    }
    private func resetView() {
           image = nil
           predictionResult = nil
           diagResult = nil
           diagResultString = nil
           documentID = nil
           result = nil
           selectedLocation = nil
           showForm = false
       }
    func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func predictImage(image: UIImage) {
        let currentLocation = selectedLocation
        
        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("Failed to convert image to pixel buffer")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let riskPrediction = try self.riskClassifier.prediction(input_1: pixelBuffer)
                let riskLogits = riskPrediction.linear_0
                let riskProbabilities = self.softmax(riskLogits)
                let predictedRiskClass = riskProbabilities.argmax()
                let riskResult = predictedRiskClass == 0 ? "Benign" : "Malignant"
                
                var diagResultValue: Int? = nil
                var diagResultStringValue: String = "Diagnosis not available"
                
                if predictedRiskClass == 1 {
                    let diagnosis = try self.diagnoser.prediction(input_1: pixelBuffer)
                    let diagnoserLogits = diagnosis.linear_0
                    let diagnoserProbabilities = self.softmax(diagnoserLogits)
                    diagResultValue = diagnoserProbabilities.argmax()
                    diagResultStringValue = conditions[diagResultValue ?? -1]
                    
                    print(diagResultValue ?? "No result")
                    print(diagResultStringValue)
                } else {
                    diagResultValue = -1
                    diagResultStringValue = "Normal"
                }
                
                DispatchQueue.main.async {
                    self.predictionResult = riskResult
                    self.result = riskResult
                    self.diagResult = diagResultValue
                    self.diagResultString = diagResultStringValue
                    
                    Task {
                        if let userEmail = Auth.auth().currentUser?.email {
                            let documentID = userEmail.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
                            print("Document ID: \(documentID)")
                            print("Email Address: \(userEmail)")
                            
                            if let location = selectedLocation, !location.isEmpty,
                               !riskResult.isEmpty, !diagResultStringValue.isEmpty {
                                
                            await firestoreManager.updateDocumentWithPrediction(documentID: documentID, location: location, risk: riskResult, diagnosis: diagResultStringValue)
                            } else {
                                print("One or more required values are nil or empty")
                            }
                        } else {
                            print("User email is nil, cannot update Firestore")
                        }
                    }
                }
            } catch {
                print("Prediction error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.predictionResult = "Prediction failed"
                    self.diagResult = 0
                }
            }
        }
    }
    
    private func softmax(_ logits: MLMultiArray) -> [Double] {
        let values = (0..<logits.count).map { logits[$0].doubleValue }
        let expValues = values.map { exp($0) }
        let sumExpValues = expValues.reduce(0, +)
        let probabilities = expValues.map { $0 / sumExpValues }
        return probabilities
    }
    
    private func processDiagnosisOutput(_ output: MLMultiArray) -> [Float32] {
        guard let array = output as? MLMultiArray else {
            print("Failed to cast output to MLMultiArray")
            return []
        }
        return (0..<array.count).map { array[$0].floatValue }
    }
    private func loadImage(from path: String) -> UIImage? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path) else {
            print("File does not exist at path: \(path)")
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}

extension Array where Element == Double {
    func argmax() -> Int {
        guard !isEmpty else { return -1 }
        return self.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0
    }
}
extension Array where Element == Float32 {
    func argmax() -> Int {
        guard !isEmpty else { return -1 }
        return self.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0
    }
}

extension MLMultiArray {
    func argmax() -> Int {
        var maxIndex = 0
        var maxValue = self[0].doubleValue
        for i in 1..<self.count {
            let currentValue = self[i].doubleValue
            if currentValue > maxValue {
                maxIndex = i
                maxValue = currentValue
            }
        }
        return maxIndex
    }
}

extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let targetSize = CGSize(width: 299, height: 299)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = resizedImage?.cgImage else {
            print("Failed to get CGImage from resized UIImage")
            return nil
        }
        
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(targetSize.width), Int(targetSize.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("Failed to create pixel buffer, status: \(status)")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .init(rawValue: 0))
        let pixelaData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelaData,
                                width: Int(targetSize.width),
                                height: Int(targetSize.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        CVPixelBufferUnlockBaseAddress(buffer, .init(rawValue: 0))
        
        return buffer
    }
}
#Preview {
    SecondView()
        .previewDevice("iPhone 15 Pro")
}



