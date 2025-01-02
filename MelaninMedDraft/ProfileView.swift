import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import UserNotifications
import MapKit
import SafariServices
import CoreLocation

struct ProfileView: View {

    class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
        private var locationManager: CLLocationManager
        @Published var currentLocation: CLLocationCoordinate2D?

        override init() {
            locationManager = CLLocationManager()
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            requestLocation()
        }

        func requestLocation() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                currentLocation = location.coordinate
                locationManager.stopUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    }

    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var isEditing: Bool = false
    @State private var navigateToLoginView = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        VStack {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 90)
                                .foregroundColor(.white)
                            
                            Text("Hello, \(firstName)!")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        .cornerRadius(12)
                        .padding()
                        
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .cornerRadius(12)
                        .background(Color(hex: colorPalette[1]))
                        .ignoresSafeArea(edges: .top)
                    }
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        if !isEditing {
                            Text("First Name: \(firstName)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 4)
                        } else {
                            TextField("First Name", text: $firstName)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: colorPalette[2]).opacity(1))
                                .cornerRadius(10)
                            
                        }
                        
                        if !isEditing {
                            Text("Last Name: \(lastName)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 4)
                        } else {
                            TextField("Last Name", text: $lastName)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: colorPalette[2]).opacity(1))
                                .cornerRadius(10)
                        }
                        
                        if !isEditing {
                            Text("Email: \(email)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.7), radius: 5, x: 0, y: 4)
                        } else {
                            TextField("Email", text: $email)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(hex: colorPalette[2]).opacity(1))
                                .cornerRadius(10)
                            
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Button(action: {
                            isEditing.toggle()
                            let documentID = email.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
                            
                            Task {
                                await editProfileInfo(
                                    documentID: documentID,
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email
                                )
                            }
                        }) {
                            Text(isEditing ? "Save Information" : "Edit Information")
                                .padding()
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: colorPalette[2]))
                                .cornerRadius(10)
                        }
                    }
                    
                    
                    .frame(maxWidth: .infinity, alignment: .center)
                    VStack {
                        DermatologistSearchView()
                            .cornerRadius(15)
                            .padding(.horizontal)
                            .padding(.vertical)
                            .background(Color(hex: colorPalette[4]))
                            .cornerRadius(15)
                            .padding(.bottom, 30)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .onAppear {
            fetchUserData()
               }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func editProfileInfo(documentID: String, firstName: String, lastName: String, email: String) async {
        let db = Firestore.firestore()
        
        do {
            let ref = db.collection("profiles").document(documentID)
            try await ref.updateData([
                "firstName": firstName,
                "lastName": lastName,
                "email": email
            ])
            print("Profile updated: \(firstName) \(lastName), Email: \(email)")
        } catch {
            print("Error updating profile: \(error)")
        }
    }
    
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        if let userEmail = user.email {
            let documentID = userEmail.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
            db.collection("profiles").document(documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data() {
                        self.firstName = data["firstName"] as? String ?? ""
                        self.lastName = data["lastName"] as? String ?? ""
                        self.email = userEmail
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    
    struct SafariView: UIViewControllerRepresentable {
        let url: URL
        
        func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
            return SFSafariViewController(url: url)
        }
        
        func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
    }
    
    struct DermatologistSearchView: View {
        @State private var searchResults: [MKMapItem] = []
        @State private var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        @State private var address: String = ""
        @State private var errorMessage: String = ""
        @State private var searchCompleter = MKLocalSearchCompleter()
        @State private var completions: [MKLocalSearchCompletion] = []
        @State private var selectedItem: MKMapItem? = nil
        @State private var isShowingSafari = false
        @StateObject private var locationManager = LocationManager()
        
        var body: some View {
            VStack {
                VStack {
                    Text("Find Dermatologists Near You")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    TextField("Enter Address", text: $address, onEditingChanged: { _ in
                        searchCompleter.queryFragment = address
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.trailing, 8)
                    
                    List(completions, id: \.self) { completion in
                        Button(action: {
                            address = completion.title
                            fetchCoordinates(for: address)
                        }) {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .font(.headline)
                                Text(completion.subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    
                    Button(action: {
                                   if let currentLocation = locationManager.currentLocation {
                                       errorMessage = ""
                                       mapRegion = MKCoordinateRegion(
                                           center: currentLocation,
                                           span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                       )
                                       print("Current location: \(currentLocation.latitude), \(currentLocation.longitude)")
                                       searchForDermatologists()
                                   } else {
                                       errorMessage = "Failed to get your location"
                                   }
                               }) {
                                   Text("Click to use current location.")
                                       .foregroundColor(.black)
                                       .padding(.horizontal, 10)
                                       .padding(.vertical, 10)
                                       .background(.white)
                                       .cornerRadius(10)
                               }
                    
                    Button(action: {
                        errorMessage = ""
                        fetchCoordinates(for: address)
                    }) {
                        Text("Search")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding()
                   
                    
                    
                    MapView(mapItems: searchResults, mapRegion: $mapRegion, selectedItem: $selectedItem, isShowingSafari: $isShowingSafari)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: 350)
                }
                .padding()
                .onAppear() {
                    locationManager.requestLocation()
                }
                /* .onAppear {
                 searchCompleter.delegate = SearchCompleterDelegate(completer: searchCompleter, completions: $completions)
                 } */
                .sheet(isPresented: $isShowingSafari) {
                    if let selectedItem = selectedItem {
                        SafariView(url: createGoogleSearchURL(for: selectedItem.name ?? ""))
                    }
                }
            }
        }
        
        func fetchCoordinates(for address: String) {
            searchResults.removeAll()
            errorMessage = ""
            let geoCoder = CLGeocoder()
            
            geoCoder.geocodeAddressString(address) { (placemarks, error) in
                if let error = error as? CLError {
                    if error.code == .geocodeFoundNoResult {
                        errorMessage = "Not enough information \nin the address."
                    } else {
                        errorMessage = "Geocoding error: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let placemark = placemarks?.first, let location = placemark.location else {
                    errorMessage = "No location found for the address."
                    return
                }
                
                mapRegion.center = location.coordinate
                mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                searchForDermatologists()
            }
        }
        
        func createGoogleSearchURL(for query: String) -> URL {
            let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "https://www.google.com/search?q=\(searchQuery)"
            return URL(string: urlString)!
        }
        
        func searchForDermatologists() {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "dermatologist"
            request.region = mapRegion
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                if let error = error {
                    errorMessage = "Search error: \(error.localizedDescription)"
                    return
                }
                
                guard let response = response else {
                    errorMessage = "No results found."
                    return
                }
                
                self.searchResults = response.mapItems
                if let firstItem = response.mapItems.first {
                    self.mapRegion.center = firstItem.placemark.coordinate
                }
            }
        }
    }
    struct SkinColor: View {
        var action: () -> Void
        var isSelected: Bool
        var title: String
        var image: String
        var isLarge: Bool = false
        
        var body: some View {
            Button(action: action) {
                HStack {
                    Spacer()
                    
                    VStack {
                        ZStack {
                            
                            if isLarge {
                                Circle()
                                    .fill(Color(hex: colorPalette[4]).opacity(0.8))
                                    .frame(width: 60, height: 60)                                                      .offset(y: 0)
                            }
                            
                            Image(systemName: image)
                                .font(.system(size: isLarge ? 30 : 20))
                                .foregroundColor(
                                    isSelected && isLarge ? Color.black :
                                        (!isSelected && isLarge ? Color.white :
                                            (isSelected && !isLarge ? Color(hex: colorPalette[1]) : Color.gray))
                                )
                                .scaleEffect(isSelected && !isLarge ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isSelected)
                        }
                        
                        Text(title)
                            .font(.caption)
                            .foregroundColor(isSelected && isLarge ? Color.black : (isSelected ? Color(hex: colorPalette[1]) : Color.gray))
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
    }
    
    struct MapView: UIViewRepresentable {
        var mapItems: [MKMapItem]
        @Binding var mapRegion: MKCoordinateRegion
        @Binding var selectedItem: MKMapItem?
        @Binding var isShowingSafari: Bool
        
        func makeCoordinator() -> MapViewCoordinator {
            return MapViewCoordinator(self)
        }
        
        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.isZoomEnabled = true
            mapView.delegate = context.coordinator
            return mapView
        }
        
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
            uiView.setRegion(mapRegion, animated: true)
            uiView.removeAnnotations(uiView.annotations)
            
            let annotations = mapItems.map { item -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.title = item.name
                annotation.coordinate = item.placemark.coordinate
                print("Annotation title: \(annotation.title ?? "No title")")
                
                return annotation
            }
            
            uiView.addAnnotations(annotations)
            print("Annotations added: \(annotations.count)")
        }
        
        class MapViewCoordinator: NSObject, MKMapViewDelegate {
            var parent: MapView
            
            init(_ parent: MapView) {
                self.parent = parent
            }
            
            func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                print("Annotation View Selected")
                
                if let annotation = view.annotation as? MKPointAnnotation,
                   let annotationTitle = annotation.title {
                    
                    let query = annotationTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    let googleSearchUrl = "https://www.google.com/search?q=\(query)"
                    
                    print("Opening Google search for: \(annotationTitle)")
                    
                    parent.selectedItem = nil
                     
                    if let url = URL(string: googleSearchUrl) {
                        UIApplication.shared.open(url)
                    }
                } else {
                    print("No title found for annotation")
                }
            }
        }
    }
}
