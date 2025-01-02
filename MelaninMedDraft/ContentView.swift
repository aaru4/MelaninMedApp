import SwiftUI
import Foundation
import SwiftData
import SafariServices
import FirebaseFirestore
import UserNotifications
import FirebaseCore
import FirebaseAuth

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

extension UIColor {
    convenience init(_ color: Color) {
        let components = color.cgColor?.components ?? [0, 0, 0, 1]
        self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

struct Scan: Identifiable, Hashable {
    var id: String
    var risk: String
    var diagnosis: String
    var date: Date
    var location: String
}

let colorPalette = ["EFAF96", "ea9087", "cb8d9a", "9d98ae", "8497b5", "4d6080"]


struct CreateProfileView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPass: String = ""
    @State private var selectedSkinType: String = "Type I"
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var profileError = false
    @State private var keyboardHeight: CGFloat = 0

    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 40)

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 120, maxHeight: 120)
                        .foregroundColor(Color(hex: colorPalette[3]))

                    Text("Create Your Profile")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: colorPalette[3]))
                        .padding(.top, 20)

                    VStack(alignment: .leading) {
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                    }

                    VStack(alignment: .leading) {
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                    }

                    // Email
                    VStack(alignment: .leading) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                    }

                    // Password
                    VStack(alignment: .leading) {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading) {
                        SecureField("Confirm Password", text: $confirmPass)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .autocapitalization(.none)
                    }
                    
                    
                    Button(action: {
                        if (password != confirmPass) {
                            alertMessage = "Passwords do not match."
                            profileError = true
                            showAlert = true
                        } else if !(firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
                            profileError = false
                            saveProfile()
                            alertMessage = "Your information will not be shared with anyone."
                            showAlert = true
                        } else {
                            alertMessage = "Please fill out all fields."
                            profileError = true
                            showAlert = true
                        }
                    }) {
                        Text("Save Profile")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color(hex: colorPalette[3]))
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .alert(isPresented: $showAlert) {
                        if !profileError {
                            Alert(title: Text("Profile Saved"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        } else {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(.bottom, keyboardHeight)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                print("Keyboard Height: \(keyboardHeight)")

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        keyboardHeight = keyboardSize.cgRectValue.height
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
            .onDisappear {
                print("Keyboard Height: \(keyboardHeight)")

                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }

            .padding(.bottom, 0)
        }
    }
              
    private func saveProfile() {
        guard !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill out all fields."
            profileError = true
            showAlert = true
            return
        }

        let db = Firestore.firestore()
        let profileData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email
        ]
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Error creating user: \(error.localizedDescription)"
                profileError = true
                showAlert = true
                return
            }
            
            let sanitizedEmail = self.sanitizeEmail(email)
            
            db.collection("profiles").document(sanitizedEmail).setData(profileData) { error in
                if let error = error {
                    alertMessage = "Error saving profile: \(error.localizedDescription)"
                    profileError = true
                } else {
                    alertMessage = "Your information will not be shared with anyone."
                    self.clearFields()
                }
                showAlert = true
            }
        }
    }

    private func sanitizeEmail(_ email: String) -> String {
        return email.replacingOccurrences(of: ".", with: "_")
                     .replacingOccurrences(of: "@", with: "_")
    }

    
    private func clearFields() {
        firstName = ""
        lastName = ""
        email = ""
        password = ""
    }
}

enum NotificationInterval: String, CaseIterable, Identifiable {
    case oneWeek = "1 Week"
    case twoWeeks = "2 Weeks"
    case threeWeeks = "3 Weeks"
    case fourWeeks = "4 Weeks"

    var id: String { self.rawValue }
}

struct NotifView: View {
    @State private var showAlert = false
    @State private var showSheet = false
    @State private var selectedInterval: NotificationInterval = .oneWeek
    @State private var showPopup = false
    @State private var showEnableButton = true
    @State private var notificationsEnabled = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("\n\n")
                Image(systemName: "bell.fill")
                    .resizable()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .foregroundColor(Color(hex: colorPalette[4]))
                
                if notificationsEnabled {
                    Text("")
                        Text("Notifications Enabled!")
                            .font(.headline)
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .foregroundColor(Color(hex: colorPalette[4]))
                            .cornerRadius(10)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: notificationsEnabled)
                    }
                    

                if showEnableButton && !showPopup {
                    Button(action: {
                                        if notificationsEnabled {
                                            Text("Notifications set up!")
                                                .font(.headline)
                                                .padding()
                                                .cornerRadius(10)
                                                .frame(maxWidth: .infinity)
                                                .background(Color.white)
                                                .foregroundColor(Color(hex: colorPalette[4]))
                                                
                                        } else {
                                            requestPermission {
                                                showPopup = true
                                            }
                                        }
                                    }) {

                        VStack {
                            Text("Enable Notifications")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(Color(hex: colorPalette[4]))
                                .cornerRadius(10)
                            
                            Text("We'll remind you to visit your doctor for high-risk abnormalities, as well as to re-scan concerning lesions.")
                                .font(.subheadline)
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: 180)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
            }
            
            if showPopup {
                Color.white.opacity(0.4)

                NotificationPopup(selectedInterval: $selectedInterval, onSchedule: {
                    scheduleNotification(interval: selectedInterval)
                    showPopup = false
                    showEnableButton = false
                    notificationsEnabled = true
                  /*  Text("Notifications set up!")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .background(Color.white)
                        .foregroundColor(Color(hex: colorPalette[4])) */
                        
                }, onDismiss: {
                    showPopup = false
                    showEnableButton = true
                })
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showPopup)
            }
        }
    }
    
    private func requestPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted!")
                completion()
            } else if let error = error {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }

    public func scheduleNotification(interval: NotificationInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Scan Skin Concerns"
        content.body = "Check developing surface lesions for malignancy now."
        content.sound = UNNotificationSound.default

        let timeInterval: TimeInterval
        switch interval {
        case .oneWeek:
            timeInterval = 7 * 24 * 60 * 60
        case .twoWeeks:
            timeInterval = 14 * 24 * 60 * 60
        case .threeWeeks:
            timeInterval = 21 * 24 * 60 * 60
        case .fourWeeks:
            timeInterval = 28 * 24 * 60 * 60
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification request: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(interval.rawValue)")
            }
        }
    }
}


struct NotificationPopup: View {
    @Binding var selectedInterval: NotificationInterval
    var onSchedule: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Notification Frequency")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: colorPalette[4]))
                .padding(.bottom, 10)

            
            ForEach(NotificationInterval.allCases) { interval in
                intervalButton(for: interval)
            }

            actionButtons
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 15)
        .frame(width: 320)
        .transition(.scale)
    }

    public func intervalButton(for interval: NotificationInterval) -> some View {
        Button(action: {
            selectedInterval = interval
        }) {
            HStack {
                Text(interval.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(selectedInterval == interval ? .white : Color(hex: colorPalette[4]))
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(buttonBackground(for: interval))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
        }
    }

    private func buttonBackground(for interval: NotificationInterval) -> AnyView {
        if selectedInterval == interval {
            return AnyView(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: colorPalette[2]), Color(hex: colorPalette[3])]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            return AnyView(Color.white)
        }
    }

    private var actionButtons: some View {
        HStack {
            Button(action: onDismiss) {
                Text("Cancel")
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
            }
            .padding(.trailing, 10)

            Button(action: onSchedule) {
                Text("Schedule")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color(hex: colorPalette[4]))
                    .cornerRadius(8)
                    .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
            }
        }
    }
}


struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        descriptions: [
                            try! AttributedString(markdown: "Skin cancer is the **most common cancer** in the US."),
                            try! AttributedString(markdown: "AI classifiers can help with early detection, boosting survival from 35% to 94%."),
                            try! AttributedString(markdown: "However, almost **all** detection apps **ignore darker skin**, excluding it from training and testing.")
                        ],
                        customFontStyles: [.subheadline, .subheadline, .headline],
                        gradientColor: colorPalette[0], 
                        isOnboardingComplete: $isOnboardingComplete,
                        image: nil,
                        currentPage: $currentPage
                    ).tag(0)
                    
                    OnboardingPage(
                        descriptions: [
                            try! AttributedString(markdown: "Enter **MelaninMed**, the first AI skin detection app designed for dark skin."),
                            try! AttributedString(markdown: "MelaninMed has **99% accuracy** in detecting malignancy and diagnosing **78 conditions**, equally effective across **all skin tones**.")
                        ],
                        customFontStyles: [.headline, .subheadline],
                        gradientColor: colorPalette[1],
                        isOnboardingComplete: $isOnboardingComplete,
                        image: Image(systemName: "person.3.fill"),
                        currentPage: $currentPage
                    ).tag(1)
                    
                    OnboardingPage(
                        descriptions: [
                            try! AttributedString(markdown: "It's simple:"),
                            try! AttributedString(markdown: "Step 1: Create a profile."),
                            try! AttributedString(markdown: "Step 2: Upload a picture."),
                            try! AttributedString(markdown: "Step 3: Get an evaluation within seconds."),
                    
                        ],
                        customFontStyles: [.headline, .subheadline, .subheadline, .subheadline],
                        gradientColor: colorPalette[2],
                        isOnboardingComplete: $isOnboardingComplete,
                        image: Image(systemName: "camera.fill"),
                        currentPage: $currentPage
                    ).tag(2)
                    
                    OnboardingPage(
                        descriptions: [
                            try! AttributedString(markdown: "create a profile"),
                        ],
                        customFontStyles: [.headline, .subheadline],
                        gradientColor: colorPalette[3],
                        isOnboardingComplete: $isOnboardingComplete,
                        image: Image(systemName: "person.crop.circle.fill.badge.plus"),
                        currentPage: $currentPage
                    ).tag(3)
                    
                    OnboardingPage(
                        descriptions: [
                            try! AttributedString(markdown: "enable notifs"),
                        ],
                        customFontStyles: [.headline, .subheadline],
                        gradientColor: colorPalette[4],
                        isOnboardingComplete: $isOnboardingComplete,
                        image: Image(systemName: "bell.fill"),
                        currentPage: $currentPage
                    ).tag(4)
                    
                   
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .ignoresSafeArea()
            }
        }
    }
}

struct OnboardingPage: View {
    let descriptions: [AttributedString]
    let customFontStyles: [Font]
    let gradientColor: String
    @Binding var isOnboardingComplete: Bool
    let image: Image?
    @State private var showDescription = false
    @State private var cardVisible = [false, false, false, false, false, false]
    @State private var navigateToHome = false
    @Binding var currentPage: Int
    
    var body: some View {
        
        VStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "FFFFFF"),
                        Color(hex: gradientColor)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    ForEach(0..<6, id: \.self) { index in
                        if currentPage == index {
                            VStack {
                                
                                if index == 3 {
                                    CreateProfileView()
                                        .transition(.opacity)
                                        .opacity(cardVisible[index] ? 1 : 0)
                                        .animation(.easeInOut(duration: 2).delay(0), value: cardVisible[index])
                                        .padding()
                                        .onAppear {
                                            withAnimation {
                                                cardVisible[index] = true
                                            }
                                        }
                                } else if index == 4 {
                                    NotifView()
                                        .transition(.opacity)
                                        .opacity(cardVisible[index] ? 1 : 0)
                                        .animation(.easeInOut(duration: 2).delay(0), value: cardVisible[index])
                                        .padding()
                                        .onAppear {
                                            withAnimation {
                                                cardVisible[index] = true
                                            }
                                        }
                                } else if index == 0 {
                                    Text("Welcome to MelaninMed!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding(20)
                                        .animation(.easeInOut(duration: 3), value: currentPage)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    showDescription = true
                                                }
                                            }
                                        }
                                    
                                    if showDescription {
                                        CardView(descriptions: descriptions, customFontStyles: customFontStyles, image: image, gradientColor: gradientColor)
                                            .transition(.opacity)
                                            .animation(.easeInOut(duration: 2), value: showDescription)
                                    }
                                } else {
                                    CardView(descriptions: descriptions, customFontStyles: customFontStyles, image: image, gradientColor: gradientColor)
                                        .transition(.opacity)
                                        .opacity(cardVisible[index] ? 1 : 0)
                                        .animation(.easeInOut(duration: 2).delay(0), value: cardVisible[index])
                                        .padding()
                                        .onAppear {
                                            withAnimation {
                                                cardVisible[index] = true
                                            }
                                        }
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
              Button(action: {
                    if currentPage < 4 {
                        currentPage += 1
                    } else {
                        isOnboardingComplete = true
                        UserDefaults.standard.set(true, forKey: "isOnboardingComplete")
                    }
                }) {
                    Text(currentPage == 4 ? "Get Started" : "Continue")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(Color(hex: gradientColor))
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.bottom, 40)
                .ignoresSafeArea()
            }
    

            
        }

}

struct CardView: View {
    let descriptions: [AttributedString]
    let customFontStyles: [Font]  
    let image: Image?
    let gradientColor: String

    var body: some View {
        if let image = image {
                       image
                           .resizable()
                           .scaledToFit()
                           .frame(maxWidth: .infinity, maxHeight: 120)
                           .aspectRatio(contentMode: .fit)
                           .padding(.bottom, 20)
                           .foregroundColor(Color(hex: gradientColor))
                           .clipped()
                   }
        
        VStack(alignment: .leading) {
            ForEach(0..<descriptions.count, id: \.self) { index in
                Text(descriptions[index])
                    .font(customFontStyles[index])
                    .foregroundColor(.black)
                    .padding(.bottom, 10)
            }
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isOnboardingComplete = UserDefaults.standard.bool(forKey: "isOnboardingComplete")
    @State private var showMainView = false
    @State private var isAuthenticated = false
    @State private var selectedTab = 0
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        let customColor = Color(hex: "FFFFFF")
        tabBarAppearance.backgroundColor = UIColor(customColor)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if !isOnboardingComplete {
                    OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                        .edgesIgnoringSafeArea(.all)
                    
                }  else if !isAuthenticated {
                     LoginView(isAuthenticated: $isAuthenticated, isOnboardingComplete: $isOnboardingComplete)
                     .transition(.opacity)
                     .animation(.easeInOut(duration: 2.5), value: isAuthenticated)
                     
                } else {
                    switch selectedTab {
                    case 0:
                        HomeView()
                            .transition(.opacity)
                                  .animation(.easeInOut(duration: 3), value: selectedTab)
                    case 1:
                        ProfileView()
                    case 2:
                        SecondView()
                    case 3:
                        ReadingView()
                    case 4:
                        ChatView()
                    default:
                        HomeView()
                            .transition(.opacity)
                                  .animation(.easeInOut(duration: 3), value: selectedTab)
                    }
                                }
                            }
                            .padding(.bottom, 0) 
            
                            CustomTabBar(selectedTab: $selectedTab, isAuthenticared: $isAuthenticated)
                                .frame(height: 100)
                                .background(Color.white)
                        }
                        .edgesIgnoringSafeArea(.bottom)
                        .background(Color.white.edgesIgnoringSafeArea(.all))
                    }
                }
    
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var isAuthenticared: Bool

    var body: some View {
        if isAuthenticared {
            GeometryReader { geometry in
                HStack {
                    TabButton(action: { selectedTab = 0 }, isSelected: selectedTab == 0, title: "Home", image: "house")
                    
                    TabButton(action: { selectedTab = 1 }, isSelected: selectedTab == 1, title: "Profile", image: "person.crop.circle.fill")
                    
                    TabButton(action: { selectedTab = 2 }, isSelected: selectedTab == 2, title: "Scan", image: "camera", isLarge: true)
                           
                    TabButton(action: { selectedTab = 3 }, isSelected: selectedTab == 3, title: "Reading", image: "book")
                    
        
                TabButton(action: { selectedTab = 4 }, isSelected: selectedTab == 4, title: "Chat", image: "message")
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color.white)
                .frame(height: 70)
            }
        }
    }
}

struct TabButton: View {
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

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String? = nil
    @State private var isEmailSent = false
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            Color(Color(hex: colorPalette[1]))
                .ignoresSafeArea()
            
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundColor(Color(hex: colorPalette[0]))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            
            VStack(spacing: 20) {
                Text("Welcome to \nMelaninMed!")
                    .foregroundColor(.white)
                    .bold()
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding(.bottom, 60)
                
                VStack(alignment: .leading) {
                    Text("Email")
                        .foregroundColor(.white)
                        .bold()
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .autocapitalization(.none)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                }
                .frame(width: 350)
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .foregroundColor(.white)
                        .bold()
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                }
                .frame(width: 350)
                
                if let error = loginError {
                    Text(error)
                        .foregroundColor(.white)
                        .font(.caption)
                }
                
                Button {
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            if let authError = error as? NSError,
                               let errorCode = AuthErrorCode(rawValue: authError.code) {
                                switch errorCode {
                                case .userNotFound:
                                    self.loginError = "Incorrect email or password."
                                case .invalidCredential:
                                    self.loginError = "Incorrect email or password."
                                default:
                                    self.loginError = error.localizedDescription
                                }
                            } else {
                                self.loginError = error.localizedDescription
                            }
                            return
                        }
                        
                        self.loginError = nil
                        isAuthenticated = true
                        
                        let db = Firestore.firestore()
                        if let userEmail = Auth.auth().currentUser?.email {
                            let documentID = userEmail.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
                            
                            if let user = Auth.auth().currentUser {
                                db.collection("profiles").document(documentID).getDocument { document, error in
                                    if let error = error {
                                        print("Error fetching user profile: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    if let document = document, document.exists {
                                        let data = document.data()
                                        print("User profile data: \(data ?? [:])")
                                    } else {
                                        print("User profile does not exist.")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    Text("Log In")
                        .bold()
                        .frame(width: 200, height: 40)
                        .background(Color(hex: colorPalette[3]))
                        .foregroundColor(.white)
                        .padding()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        isOnboardingComplete = false
                    }) {
                        Text("Don't have an account? Sign up.")
                            .foregroundColor(.white)
                            .underline()
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 8)
                
                if !isEmailSent {
                    HStack {
                        Spacer()
                        Button(action: {
                            isEmailSent = true
                            // sendPasswordReset(withEmail: $email)
                        }) {
                            VStack {
                                Text("Forgot password?")
                                    .foregroundColor(.white)
                                
                                
                                Text("Fill out your email and click here.")
                                    .foregroundColor(.white)
                                    .underline()
                                
                            }
                        }
                        
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    
                } else {
                HStack {
                    Spacer()
                    
                    Text("Password reset email sent.")
                        .foregroundColor(.white)
                    
                    
                    Spacer()
                }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                }
            }
            
            .padding()
        }
    }
}
struct HomeView: View {
    @State private var recentScans: [Scan] = []
    @State private var showFullHistory = false
    @State private var currentIndex: Int = 0
    @State private var allScans: [Scan] = []
    @State private var showingSafari = false
    @State private var flipXYZ: Angle = .zero
    @State private var colorCounter = 0
    @State private var animationState: Bool = false
    @State private var isAnimating: Bool = false
    @State private var rotation: Double = 0
    @State private var isPulsing = false
    @State private var showMoreContent = false
    @State private var firstName: String = ""
    @State private var showConditions = false
    @State private var bounce = false
    @State private var showingAlert = false
    @State private var scanToDelete: Int?
    
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

    var malignantScans: [Scan] {
        allScans.filter { $0.risk == "Malignant" }
    }
    
    var malignantCount: Int {
        malignantScans.count
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ZStack {
                        VStack {
                            Text("Welcome to MelaninMed, ")
                                .font(.title)
                                .padding(.top, 18)
                                .padding(.horizontal, 10)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)

                            Text("where healthcare is colorblind.")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 18)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: colorPalette[1]),
                                            Color(hex: colorPalette[4])
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(color: .gray, radius: 5, x: 0, y: 0)
                        .padding(.horizontal, 10)
                        .padding(.top, 15)
                    }
                }

                VStack(spacing: 12) { 
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(hex: colorPalette[0]))
                        .overlay(
                            VStack {
                                Text("Skin color shouldn't dictate healthcare access.")
                                    .font(.title3)
                                    .padding(.vertical, 5)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 15)
                            }
                            .padding(.horizontal, 15)
                            
                        )
                        .frame(width: 330, height: 70)
                        .padding(.top, 18)
               

                    HStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: colorPalette[1]))
                            .frame(width: 150, height: 180)
                            .overlay(
                                VStack {
                                    Text("The first AI skin detector")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                        .padding(.top, 8)
                                    Text("designed for dark skin.")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 8)
                                        .padding(.bottom, 8)
                                }
                            )

                        VStack(spacing: 15) {
                            RoundedRectangle(cornerRadius: 15)
                            
                                .fill(Color(hex: colorPalette[2]))
                                .frame(width: 160, height: 90)
                                .overlay(
                                    VStack(spacing: 3) {
                                        Text("Scan blemish.")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                        Text("Results within **seconds**.")
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(8)
                                )
                          //      .shadow(radius: 5)

                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: colorPalette[3]))
                                .frame(width: 160, height: 70)
                                .overlay(
                                    Text("**99% accurate**.\n 78 conditions.")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                )
                        //        .shadow(radius: 5)
                        }
                    }

                    Button(action: {
                        showConditions = true
                    }) {
                        Text("Click to View Conditions")
                            .padding()
                            .background(Color(hex: colorPalette[4]))
                            .foregroundColor(.black)
                            .cornerRadius(18)
                        //    .shadow(radius: 5)
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 2)
                    .sheet(isPresented: $showConditions) {
                        ConditionsListView(conditions: conditions, showConditions: $showConditions)
                    }
                
                .padding(.top, 10)
               
          if !showMoreContent {
                               VStack {
                                   
                                   Button(action: {
                                       withAnimation {
                                           showMoreContent = true
                                       }
                                   }) {
                                       Text("Click to Learn More")
                                           .fontWeight(.bold)
                                           .padding()
                                           .background(Color.white)
                                           .foregroundColor(Color(hex: colorPalette[4]))
                                           .cornerRadius(10)
                                   }
                                   
                                   VStack {
                                               Spacer()
                                               
                                               VStack(spacing: -10) {
                                                   Image(systemName: "chevron.down")
                                                       .font(.system(size: 20))
                                                       .padding(.bottom, 20)
                                                       .foregroundColor(.black)
                                                       .offset(y: bounce ? 10 : 0)
                                                       .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounce)
                                                
                                               }
                                               .onAppear {
                                                   bounce = true
                                               }
                                               
                                               Spacer()
                                           }
                                   
                                   Rectangle()
                                       .fill(Color.gray)
                                       .frame(height: 2)
                                       .padding(.horizontal, 16)
                                       
                               }
          } else {
              VStack {
                  Text("\n")
              }
              VStack {
                  
                  let fitzpatrickColors: [Color] = [
                    Color(hex: "ca9f81"),
                    Color(hex: "af7954"),
                    Color(hex: "895129"),
                    Color(hex: "3a2320"),
                    Color(hex: "f0d1b5"),
                    Color(hex: "dfb593")
                  ]
                  
                  VStack {
                      ZStack {
                          GeometryReader { geometry in
                              Circle()
                                  .fill(.white)
                                  .frame(width: 150, height: 150)
                                  .overlay(
                                    Text("The Fitzpatrick Scale")
                                        .font(.title3)
                                        .foregroundColor(.black)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                  )
                                  .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                              
                              ZStack {
                                  ForEach(0..<6) { index in
                                      Circle()
                                          .fill(fitzpatrickColors[index])
                                          .frame(width: 80, height: 80)
                                          .position(positionForCircle(index: index, geometry: geometry, radius: 120))
                                  }
                              }
                              .rotationEffect(.degrees(rotation))
                              .onAppear {
                                  withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: false)) {
                                      rotation = 360
                                  }
                              }
                          }
                      }
                      .frame(height: 300)
                  }
                  .padding(.bottom, 20)
                  
                  Text("\n**Only 0.47%** of our competitor's data includes brown or black skin. Their clinical trials **exclude** the last two skin tones.\n\nMelaninMed was trained on an intentionally diverse dataset, and has similar accuracy for every skin tone.\n\n")
                      .font(.subheadline)
                      .padding(.horizontal, 20)
                      .multilineTextAlignment(.leading)
                  
                  Text("MelaninMed **sees beyond skin color**.")
                      .font(.headline)
                      .padding(.horizontal, 20)
                      .multilineTextAlignment(.center)
                  
                  Button(action: {
                      withAnimation {
                          showMoreContent = false
                      }
                  }) {
                      Rectangle()
                          .fill(Color.gray)
                          .frame(height: 2)
                          .padding(.horizontal, 16)
                          .padding()
                      
                      VStack {
                          Text("Show Less")
                              .fontWeight(.bold)
                              .padding()
                              .background(Color.white)
                              .foregroundColor(Color(hex: colorPalette[4]))
                              .cornerRadius(10)
                      }
                      Rectangle()
                          .fill(Color.gray)
                          .frame(height: 2)
                          .padding(.horizontal, 16)
                          .padding()
                  }
              }
              .scrollTransition { effect, phase in
                  effect
                      .scaleEffect(phase.isIdentity ? 1 : 0.8)
              }
          }
                    VStack {
                        Text("Scan History")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding(.top, 14)
                            .padding(.horizontal, 10)
                            .padding(.bottom, 14)
                    }
                    .background(.white)
                    .cornerRadius(10)
                    .padding(.top, 15)
                    .shadow(radius: 5)
                    
                    let scanColorPalette = ["EFAF96", "ea9087", "cb8d9a", "9d98ae", "8497b5"]
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            if allScans.isEmpty {
                                HStack {
                                    Text("No scans taken.")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .padding(.top, 8)
                                        .padding(.horizontal, 10)
                                        .padding(.bottom, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: colorPalette[4])
                                                     ))
                                        .multilineTextAlignment(.center)
                                }
                                .background(Color(hex: colorPalette[4]))
                                .cornerRadius(10)
                                .padding(.horizontal, 130)
                                .padding(.bottom, 20)
                                
                            } else {
                                ForEach(Array(allScans.enumerated()), id: \.element.id) { index, scan in
                                    GeometryReader { geometry in
                                        VStack(alignment: .leading) {
                                            Text("Location: \(scan.location)")
                                                .font(.subheadline)
                                                .padding(.bottom, 4)
                                            Text("Risk: \(scan.risk)")
                                                .font(.subheadline)
                                                .padding(.bottom, 4)
                                            if scan.risk == "Malignant" {
                                                Text("Diagnosis: \(scan.diagnosis)")
                                                    .font(.subheadline)
                                                    .lineLimit(nil)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding(.bottom, 4)
                                            }
                                            Text("Date: \(dateFormatter.string(from: scan.date))")
                                                .font(.caption)
                                                .padding(.bottom, 10)
                                            
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    scanToDelete = index
                                                    showingAlert = true
                                                }) {
                                                    Image(systemName: "trash")
                                                        .foregroundColor(.black)
                                                }
                                                Spacer()
                                            }
                                        }
                                        
                                        .padding()
                                      //  .padding(.horizontal, 5)
                                        .background(Color(hex: colorPalette[index % colorPalette.count]))
                                        .cornerRadius(10)
                                        .shadow(radius: 8)
                                        .scaleEffect(getScale(for: geometry.frame(in: .global).midX))
                                        .animation(.spring(), value: currentIndex)
                                        .onTapGesture {
                                            currentIndex = index
                                        }
                                    }
                                    .frame(width: 250, height: 190)
                                }
                                
                                .padding()
                                .cornerRadius(10)
                                .padding(.top, 20)
                                .padding(.horizontal, 5)
                                
                            }
                        }
                    }
                    Rectangle()
                            .fill(Color.gray)
                            .frame(height: 2)
                            .padding(.horizontal, 16)
                    VStack {
                        VStack {
                            Text("Malignant Lesions")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding(.top, 14)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 14)
                        }
                        .background(.white)
                        .cornerRadius(10)
                        .padding(.top, 15)
                        .shadow(radius: 5)
                        
                        let malignantScans = allScans.filter { $0.risk == "Malignant" }
                        
                        if malignantScans.isEmpty {
                            Text("All scans likely benign and of no concern.")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .padding(.top, 8)
                                .padding(.horizontal, 10)
                                .padding(.bottom, 8)
                                .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color(hex: colorPalette[3])
                                        ))
                        } else {
                            VStack {
                                Text("See a dermatologist as soon as possible.")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 2)
                                
                                ForEach(Array(malignantScans.enumerated()), id: \.element.id) { index, scan in
                                    VStack(alignment: .center) {
                                        Text("\(scan.location)")
                                            .font(.subheadline)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                            //.foregroundColor(Color(hex: colorPalette[4]))
                                            .padding(.bottom, 1)
                                        
                                        Text("\(DateFormatter.localizedString(from: scan.date, dateStyle: .short, timeStyle: .none))")
                                            .font(.subheadline)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color(hex: colorPalette[3]))
                                            .padding(.bottom, 1)

                                    }
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 110, height: 110)
                                            .shadow(radius: 3)
                                    )
                                    .foregroundColor(.black)
                                    .padding(.vertical, 35)
                                    .padding(.horizontal, 10)
                                }
                            }
                                
                                .padding()
                                .background(Color(hex: colorPalette[3]))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .shadow(radius: 5)
                                .scrollTransition { effect, phase in
                                    effect
                                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                
                            }
                        }
                    }
                  
                }
                
                
                Spacer()
                    .padding(.horizontal, 3)
                    .padding(.bottom, 15)
            }
            .alert("Are you sure you want to delete this scan?", isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let index = scanToDelete {
                        deleteScan(at: index)
                    }
                }
            }
            .onAppear {
                
                fetchUserData()
                   Task {
                 guard let user = Auth.auth().currentUser, let userEmail = user.email else { return }
                 
                 let allScans = await firestoreManager.fetchAllScans(documentID: userEmail.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_"))
                 self.allScans = allScans
                 self.recentScans = Array(allScans.prefix(3))
                 }
                print("All Scans: \(allScans)")
                 
            }
        }
        }
    
    func deleteScan(at index: Int) {
        allScans.remove(at: index)
            
            }
        
    
  private func fetchUserData() {
         guard let user = Auth.auth().currentUser else { return }

         let db = Firestore.firestore()
         if let userEmail = Auth.auth().currentUser?.email {
         let documentID = userEmail.lowercased().replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
            db.collection("profiles").document(documentID).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let data = document.data(), let name = data["firstName"] as? String {
                        self.firstName = name
                    }
                } else {
                    print("Document does not exist")
                }
            }
         }
     }
 }
    
    private func positionForCircle(index: Int, geometry: GeometryProxy, radius: CGFloat) -> CGPoint {
        let angle = CGFloat(index) * (2 * .pi / 6) - .pi / 2
        let centerX = geometry.size.width / 2
        let centerY = geometry.size.height / 2
        let x = centerX + radius * cos(angle)
        let y = centerY + radius * sin(angle)
        return CGPoint(x: x, y: y)
    }
    private func getScale(for midX: CGFloat) -> CGFloat {
    let screenWidth = UIScreen.main.bounds.width
    let offset = abs(midX - screenWidth / 2)
    let scale = max(0.8, 1 - (offset / (screenWidth / 2)) * 0.2)
    return scale
}


    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    #Preview {
        ContentView()
    
}
