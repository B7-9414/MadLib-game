//
//  FilledOutMadLib.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import Foundation

struct FilledOutMadLib: Codable {
    let madLibId: Int
    let username: String
    let timestamp: String
    let answers: [Answer]
}

