//
//  StoryTitleCard.swift
//  Mad Libs
//
//  Created by Bassam on 4/5/24.
//

import SwiftUI

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
