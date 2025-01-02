//
//  ModelView.swift
//  MelaninMedDraft
//
//  Created by Aarushi Ammavajjala on 9/26/24.

import SwiftUI
import ChatGPTSwift

@MainActor
class ContentViewModel: ObservableObject {
    
    private let api: ChatGPTAPI
        init() {
            guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
                fatalError("API Key not found in environment variables. Ensure OPENAI_API_KEY is set.")
            }
            self.api = ChatGPTAPI(apiKey: apiKey)
        }
    
    @Published var message = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var isWaitingForResponse = false
    
    func sendMessage() async throws {
        let userMessage = ChatMessage(message)
        chatMessages.append(userMessage)
       
        isWaitingForResponse = true
        
        let assistantMessage = ChatMessage(owner: .assistant, "")
        chatMessages.append(assistantMessage)
        
        let stream = try await api.sendMessageStream(text: message)
        message = ""
        for try await line in stream  {
            if let lastMessage = chatMessages.last {
                let text = lastMessage.text
                let newMessage = ChatMessage(owner: .assistant, text + line)
                chatMessages[chatMessages.count - 1] = newMessage
            }
        }
        
        isWaitingForResponse = false
    }
}
