//
//  ChatMessage.swift
//  MelaninMedDraft
//
//  Created by Aarushi Ammavajjala on 9/26/24.
//

import SwiftUI

struct ChatMessage: Identifiable {
    var id = UUID().uuidString
    
    var owner: MessageOwner
    var text: String
    
    init(owner: MessageOwner = .you, _ text: String) {
        self.owner = owner
        self.text = text
    }
}
