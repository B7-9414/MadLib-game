//
//  HistoryView.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyViewModel: HistoryViewModel

    var body: some View {
        VStack {
            List(historyViewModel.history) { histo in
                NavigationLink(destination: HistoryDetailView(history: histo)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Story Title: \(histo.storyTitle)")
                            .font(.headline)
                        Text("MadLib ID: \(histo.madLibId)")
                            .font(.subheadline)
                        Text("Timestamp: \(histo.timestamp)")
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("History")
        }
        .onAppear {
            historyViewModel.fetchDataHistory()
        }
    }
}

