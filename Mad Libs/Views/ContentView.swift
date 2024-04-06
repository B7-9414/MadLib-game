import SwiftUI

struct ContentView: View {
    @StateObject private var selectedStoryManager = SelectedStoryManager()
    @State private var storyTitles: [StoryTitle] = []
    @State private var isOnline: Bool = true // Flag to track online/offline mode
    @StateObject private var historyViewModel = HistoryViewModel() // Add the HistoryViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedStoryManager.selectedStory != nil {
                    StoryDetailView(story: selectedStoryManager.selectedStory!, userInput: $selectedStoryManager.userInput, onSubmit: selectedStoryManager.submitMadLib)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(leading: backButton)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(storyTitles, id: \.id) { storyTitle in
                                Button(action: {
                                    selectedStoryManager.fetchStory(withId: storyTitle.id)
                                }) {
                                    StoryTitleCard(storyTitle: storyTitle)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        if isOnline {
                            OnlineManager.shared.fetchStoryTitlesOnline { storyTitles in
                                if let storyTitles = storyTitles {
                                    self.storyTitles = storyTitles
                                } else {
                                    print("Failed to fetch story titles no Internet connection, now fetch them from local db")
                                    // Fetch story titles from local storage if online fetch fails
                                    if let offlineStoryTitles = OfflineManager.shared.fetchStoryTitlesOffline() {
                                        self.storyTitles = offlineStoryTitles
                                    } else {
                                        print("No story titles found in local storage")
                                    }
                                }
                            }
                        } else {
                            print("Offline mode")
                            // Fetch story titles from local storage when offline
                            if let offlineStoryTitles = OfflineManager.shared.fetchStoryTitlesOffline() {
                                self.storyTitles = offlineStoryTitles
                            } else {
                                print("No story titles found in local storage")
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Mad Libs", displayMode: .inline)
            .overlay(
                VStack {
                    if selectedStoryManager.showAlert {
                        ZStack {
                            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                            VStack {
                                Text("Submission Successful")
                                    .font(.title)
                                    .padding()
                                Text(selectedStoryManager.alertMessage)
                                    .padding()
                                Button("OK") {
                                    selectedStoryManager.showAlert = false
                                    selectedStoryManager.clearInputFields()
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
            .navigationBarItems(trailing:
                NavigationLink(destination: HistoryView(historyViewModel: historyViewModel)) {
                    Text("History")
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var backButton: some View {
        Button(action: {
            selectedStoryManager.selectedStory = nil
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        }
    }
}
