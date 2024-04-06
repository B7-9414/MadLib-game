//
//  OfflineManager.swift
//  Mad Libs
//
//  Created by Bassam on 4/6/24.
//

import Foundation

class OfflineManager {
    static let shared = OfflineManager()
    
    private init() {}
    
    func fetchStoryTitlesOffline() -> [StoryTitle]? {
        // Retrieve story titles from local database
        guard let data = UserDefaults.standard.data(forKey: "storyTitles") else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let storyTitles = try decoder.decode([StoryTitle].self, from: data)
            return storyTitles
        } catch {
            print("Error decoding story titles from local database: \(error)")
            return nil
        }
    }
    
}
