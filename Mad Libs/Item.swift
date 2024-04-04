//
//  Item.swift
//  Mad Libs
//
//  Created by Bassam on 3/22/24.
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
