import SwiftUI

struct StoryDetailView: View {
    let story: Story
    @Binding var userInput: [String]
    var onSubmit: () -> Void
    
    init(story: Story, userInput: Binding<[String]>, onSubmit: @escaping () -> Void) {
        self.story = story
        self._userInput = userInput
        self.onSubmit = onSubmit
    }
    
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
