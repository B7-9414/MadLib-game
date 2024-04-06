//
//  SelectedStoryManager.swift
//  Mad Libs
//
//  Created by Bassam on 4/6/24.
//

import SwiftUI

class SelectedStoryManager: ObservableObject {
    @Published var selectedStory: Story?
    @Published var userInput: [String] = []
    @Published var isDetailShown: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    func clearInputFields() {
        self.userInput = Array(repeating: "", count: selectedStory?.questions.count ?? 0)
    }
    
    func fetchStory(withId id: Int) {
        OnlineManager.shared.fetchStory(withId: id) { [self] story in
            if let story = story {
                self.parseStory(story) // Use self explicitly to capture parseStory
            } else {
                print("Failed to fetch story")
            }
        }
    }
    
    
    func parseStory(_ story: Story) {
        DispatchQueue.main.async {
            self.selectedStory = story
            self.userInput = Array(repeating: "", count: story.questions.count)
            self.isDetailShown = true
        }
    }
    
    func submitMadLib() {
        guard let selectedStory = selectedStory else {
            print("No story selected")
            return
        }
        
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let timestampString = dateFormatter.string(from: Date())
        
        let answers: [Answer] = selectedStory.questions.map { question in
            let userInputIndex = selectedStory.questions.firstIndex { $0.id == question.id }!
            return Answer(questionId: question.id, answerValue: userInput[userInputIndex])
        }
        
        let filledOutMadLib = FilledOutMadLib(madLibId: selectedStory.id, username: "banaw002", timestamp: timestampString, answers: answers)
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(filledOutMadLib)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Data to be sent:")
                print(jsonString)
            }
            
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async { // Ensure main thread execution
                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Mad Lib submitted successfully: \(responseString)")
                            self.alertMessage = responseString
                            self.showAlert = true
                        } else {
                            print("Failed to decode response as UTF-8 string")
                        }
                    } else if let error = error {
                        print("Error submitting Mad Lib: \(error)")
                    }
                }
            }.resume()
        } catch {
            print("Error encoding Mad Lib: \(error)")
        }
    }
}
