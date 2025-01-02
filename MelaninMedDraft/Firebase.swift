import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Initializes Firebase
        return true
    }

    func fetchAllScans(documentID: String) async -> [Scan] {
        let db = Firestore.firestore()
        let usersCollection = db.collection("profiles").document(documentID).collection("predictions")
           
        print("Fetching last three scans...")
            
            do {
                let querySnapshot = try await usersCollection.order(by: "date", descending: true).getDocuments()
                       
                var scans: [Scan] = []
                
                for document in querySnapshot.documents {
                    let data = document.data()
                    print("Processing document \(document.documentID)...")
                    
                    if let timestamp = data["date"] as? Timestamp,
                       let location = data["location"] as? String,
                       let risk = data["risk"] as? String,
                       let diagnosis = data["diagnosis"] as? String {
                        
                        // Convert Timestamp to Date
                        let date = timestamp.dateValue()
                        
                        // Create Scan object
                        let scan = Scan(id: document.documentID, risk: risk, diagnosis: diagnosis, date: date, location: location)
                        scans.append(scan)
                        print("Added scan: \(scan)")
                    } else {
                        print("Error: Missing or invalid fields in document \(document.documentID).")
                    }
                }
                
                return scans
            } catch {
                print("Error fetching scans: \(error)")
                return []
            }
        }
        
        // Function to update an existing document with prediction data
    func updateDocumentWithPrediction(documentID: String, location: String, risk: String, diagnosis: String) async {
            let db = Firestore.firestore()
            
            do {
                let ref = db.collection("profiles").document(documentID).collection("predictions")
                let _ = try await ref.addDocument(data: [
                    "date": FieldValue.serverTimestamp(),
                    "location": location,
                    "risk": risk,
                    "diagnosis": diagnosis
                    
                ])
                print("Document ID: \(documentID), Location: \(location), Risk: \(risk), Diagnosis: \(diagnosis)")
                print("Document updated with prediction: \(risk)")
            } catch {
                print("Error updating document: \(error)")
            }
        }
    
}
