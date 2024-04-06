//
//  OnlineManager.swift
//  Mad Libs
//
//  Created by Bassam on 4/6/24.
//

import Foundation

class OnlineManager {
    static let shared = OnlineManager()
    
    private init() {}
    
    func fetchStoryTitlesOnline(completion: @escaping ([StoryTitle]?) -> Void) {
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/MadLib") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    print("Error: The Internet connection appears to be offline.")
                    completion(nil)
                } else {
                    print("Error fetching story titles: \(error)")
                    completion(nil)
                }
                return
            }
            
            guard let data = data else {
                print("No data received when fetching story titles")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let storyTitles = try decoder.decode([StoryTitle].self, from: data)
                completion(storyTitles)
            } catch {
                print("Error decoding story titles: \(error)")
                completion(nil)
            }
        }.resume()
    }
    func fetchStory(withId id: Int, completion: @escaping (Story?) -> Void) {
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/MadLib/\(id)") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let story = try decoder.decode(Story.self, from: data)
                    completion(story)
                } catch {
                    print("Error decoding story: \(error)")
                    completion(nil)
                }
            } else if let error = error {
                print("Error fetching story: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func saveStoryTitlesToLocalDatabase(_ data: Data) {
        // Save fetched story titles to UserDefaults
        UserDefaults.standard.set(data, forKey: "storyTitles")
    }
    
}
