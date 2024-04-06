//
//  HistoryViewModel.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import Foundation
import Network

class HistoryViewModel: ObservableObject {
    @Published var history: [History] = []
    
    // Computed property to check if the network is available
    private var isNetworkAvailable: Bool {
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)
        
        NetworkManager.shared.checkNetworkAvailability { isAvailable in
            isConnected = isAvailable
            semaphore.signal()
        }
        
        semaphore.wait()
        return isConnected
    }

    func fetchDataHistory() {
        if isNetworkAvailable {
            // Fetch data from the web service
            guard let url = URL(string: "https://seng5199madlib.azurewebsites.net/api/PostMadLib?username=banaw002") else {
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }

                if let decodedResponse = try? JSONDecoder().decode([History].self, from: data) {
                    DispatchQueue.main.async {
                        self.history = decodedResponse
                        self.saveHistoryToLocalStorage(data)
                    }
                    return
                }

                print("Error: Unable to decode JSON response")
            }.resume()
        } else {
            // Fetch data from local storage when offline
            fetchHistoryFromLocalStorage()
        }
    }

    private func saveHistoryToLocalStorage(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "history")
    }

    private func fetchHistoryFromLocalStorage() {
        guard let data = UserDefaults.standard.data(forKey: "history") else { return }

        if let decodedResponse = try? JSONDecoder().decode([History].self, from: data) {
            DispatchQueue.main.async {
                self.history = decodedResponse
            }
            return
        }

        print("Error: Unable to decode history data from local storage")
    }
}
