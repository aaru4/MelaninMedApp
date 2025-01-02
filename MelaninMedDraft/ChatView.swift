import SwiftUI

struct ChatView: View {

    @StateObject private var viewModel = ContentViewModel()
    @State private var keyboardHeight: CGFloat = 0
    let colorPalette = ["EFAF96", "ea9087", "cb8d9a", "9d98ae", "8497b5", "4d6080"]
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack {
                        Text("AI Dermatologist")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top)
                            .padding(.bottom, 8)

                        Text("Ask MelaninMed's state-of-the-art dermatology chatbot anything.")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        
                        Text("Example Messages:")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 0) {
                        ZStack {
                            Color(hex: colorPalette[0])
                            Text("What can I do for dry skin on my face?")
                                .font(.subheadline)
                                .padding()
                                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                        }
                        .cornerRadius(50)
                    
                        ZStack {
                            Color(hex: colorPalette[1])
                            Text("How to alleviate itching around a scar?")
                                .font(.subheadline)
                                .padding()
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                        }.cornerRadius(50)
                        ZStack {
                            Color(hex: colorPalette[2])
                            Text("Develop a budget-friendly skincare routine.")
                                .font(.subheadline)
                                .padding()
                                .cornerRadius(10)
                                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                        }.cornerRadius(50)
                        
                        Text("\n")
                    }
                   
                    .onTapGesture {
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }
                                        
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.chatMessages) { message in
                            messageView(message)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                }
                .onReceive(viewModel.$chatMessages.throttle(for: 0.5, scheduler: RunLoop.main, latest: true)) { chatMessages in
                    guard !chatMessages.isEmpty else { return }
                    withAnimation {
                        proxy.scrollTo("bottom")
                    }
                }
            }

            ZStack(alignment: .bottom) {
                HStack {
                    TextField("Message...", text: $viewModel.message)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    if viewModel.isWaitingForResponse {
                        ProgressView()
                            .padding(.trailing)
                    } else {
                        Button("Send") {
                            sendMessage()
                        }
                        .fontWeight(.bold)
                        .padding()
                        .background(Color(hex: colorPalette[4]))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.trailing)
                    }
                }
                .padding(.bottom, 20)
                .padding(.bottom, keyboardHeight)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        self.keyboardHeight = keyboardSize.height - 30
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (_) in
                    self.keyboardHeight = 0
                }
            }
           
        }
        .padding(.horizontal)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    func messageView(_ message: ChatMessage) -> some View {
        HStack {
            if message.owner == .you {
                Spacer(minLength: 60)
            }

            if !message.text.isEmpty {
                VStack {
                    Text(message.text)
                        .foregroundColor(message.owner == .you ? .black : .white)
                        .padding(12)
                        .background(message.owner == .you ? Color(hex: colorPalette[3]) : Color(hex: colorPalette[4]))
                        .cornerRadius(16)
                        .overlay(alignment: message.owner == .you ? .topTrailing : .topLeading) {
                            Text(message.owner.rawValue.capitalized)
                                .foregroundColor(.gray)
                                .font(.caption)
                                .offset(y: -16)
                        }
                }
            }

            if message.owner == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal)
    }
    
    
    func sendMessage() {
        DispatchQueue.main.async {
               UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
           }
        Task {
            do {
                try await viewModel.sendMessage()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
