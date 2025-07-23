//
//  Item.swift
//  rufus
//
//  Created by Mubashir Osmani on 2025-07-23.
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
