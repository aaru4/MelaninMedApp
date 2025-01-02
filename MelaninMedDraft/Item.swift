//
//  Item.swift
//  MelaninMedDraft
//
//  Created by Aarushi Ammavajjala on 8/19/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
