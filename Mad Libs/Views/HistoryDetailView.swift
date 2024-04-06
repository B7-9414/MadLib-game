import SwiftUI

struct HistoryDetailView: View {
    let history: History
    @State private var responseData = ""
    @State private var isOffline = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Story Title: \(history.storyTitle)")
                .font(.headline)
            Text("Timestamp: \(history.timestamp)")
                .font(.subheadline)
            Button(action: {
                fetchSelectedStoryDataHistory(id: history.filledOutMadLibId)
            }) {
                Text("Fetch Data")
            }
            if isOffline {
                Text("No internet connection. Fetching data from local storage.")
            } else {
                Text(responseData)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationTitle("Story Detail History")
        .onAppear {
            checkNetworkAvailability()
        }
    }

    func fetchSelectedStoryDataHistory(id: Int) {
        guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib/\(id)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.responseData = responseString
                }
            }
        }.resume()
    }

    func checkNetworkAvailability() {
        NetworkManager.shared.checkNetworkAvailability { isAvailable in
            DispatchQueue.main.async {
                self.isOffline = !isAvailable
            }
        }
    }
}
