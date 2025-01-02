import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

func addUserToFirestore() async {
    let db = Firestore.firestore()
    
    do {
        let ref = try await db.collection("users").addDocument(data: [
            "first": "Adaj",
            "last": "Loveljace",
            "born": 1817
        ])
        print("Document added with ID: \(ref.documentID)")
    } catch let error as NSError {
        print("Error adding document: \(error.localizedDescription)")
    }
}

