//
//  History.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//
import Foundation

struct History: Codable, Identifiable {
    let filledOutMadLibId: Int
    let madLibId: Int
    let timestamp: String
    let storyTitle: String

    var id: Int {
        return filledOutMadLibId
    }
}
