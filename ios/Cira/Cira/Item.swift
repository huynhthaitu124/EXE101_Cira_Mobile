//
//  Item.swift
//  Cira
//
//  Created by Tu Huynh on 29/11/25.
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
