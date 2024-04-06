//
//  Story.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import Foundation

struct Story: Codable {
    let id: Int
    let story: String
    let questions: [Question]
}
