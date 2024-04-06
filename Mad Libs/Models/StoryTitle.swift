//
//  StoryTitle.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import Foundation

struct StoryTitle: Codable, Identifiable {
    let id: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "storyTitle"
    }
}
