import SwiftUI

struct ContentView: View {
    @State private var storyTitles: [StoryTitle] = []
    @State private var selectedStory: Story?
    @State private var userInput: [String] = []
    @State private var isDetailShown: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedStory != nil {
                    StoryDetailView(story: selectedStory!, userInput: $userInput, onSubmit: submitMadLib)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: backButton)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(storyTitles, id: \.id) { storyTitle in
                                Button(action: {
                                    fetchStory(withId: storyTitle.id)
                                }) {
                                    StoryTitleCard(storyTitle: storyTitle)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        fetchStoryTitles()
                    }
                }
            }
            .navigationBarTitle("Mad Libs", displayMode: .inline)
            .overlay(
                VStack {
                    if showAlert {
                        ZStack {
                            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                            VStack {
                                Text("Submission Successful")
                                    .font(.title)
                                    .padding()
                                Text(alertMessage)
                                    .padding()
                                Button("OK") {
                                    showAlert = false
                                    clearInputFields()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding()
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding()
                        }
                    }
                }
            )
        }
    }
    
    var backButton: some View {
        Button(action: {
            selectedStory = nil
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        }
    }
    
    func fetchStoryTitles() {
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/MadLib") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    parseStoryTitles(responseString)
                } else {
                    print("Failed to decode response as UTF-8 string")
                }
            } else if let error = error {
                print("Error fetching story titles: \(error)")
            }
        }.resume()
    }
    
    func parseStoryTitles(_ responseString: String) {
        do {
            let decoder = JSONDecoder()
            let data = Data(responseString.utf8)
            let storyTitles = try decoder.decode([StoryTitle].self, from: data)
            DispatchQueue.main.async {
                self.storyTitles = storyTitles
            }
        } catch {
            print("Error decoding story titles: \(error)")
        }
    }
    
    func fetchStory(withId id: Int) {
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/MadLib/\(id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    parseStory(responseString)
                } else {
                    print("Failed to decode response as UTF-8 string")
                }
            } else if let error = error {
                print("Error fetching story: \(error)")
            }
        }.resume()
    }
    
    func parseStory(_ responseString: String) {
        do {
            let decoder = JSONDecoder()
            let data = Data(responseString.utf8)
            let story = try decoder.decode(Story.self, from: data)
            DispatchQueue.main.async {
                self.selectedStory = story
                self.userInput = Array(repeating: "", count: story.questions.count)
                self.isDetailShown = true
            }
        } catch {
            print("Error decoding story: \(error)")
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
            }.resume()
        } catch {
            print("Error encoding Mad Lib: \(error)")
        }
    }
    
    func clearInputFields() {
        self.userInput = Array(repeating: "", count: selectedStory?.questions.count ?? 0)
    }
}

struct StoryTitleCard: View {
    let storyTitle: StoryTitle
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .overlay(
                    Text(storyTitle.title)
                        .foregroundColor(.white)
                        .font(.title3)
                )
        }
    }
}

struct StoryDetailView: View {
    let story: Story
    @Binding var userInput: [String]
    var onSubmit: () -> Void
    
    var body: some View {
        VStack {
            Text(story.story)
                .padding()
            
            ForEach(story.questions.indices, id: \.self) { index in
                TextField(story.questions[index].description, text: $userInput[index])
                    .padding()
            }
            
            Button("Submit Mad Lib") {
                onSubmit()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct StoryTitle: Codable, Identifiable {
    let id: Int
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "storyTitle"
    }
}

struct Story: Codable {
    let id: Int
    let story: String
    let questions: [Question]
}

struct Question: Codable {
    let id: Int
    let description: String
}

struct FilledOutMadLib: Codable {
    let madLibId: Int
    let username: String
    let timestamp: String
    let answers: [Answer]
}

struct Answer: Codable {
    let questionId: Int
    let answerValue: String

}
