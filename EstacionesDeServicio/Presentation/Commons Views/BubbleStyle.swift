import SwiftUI

struct BubbleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

extension View {
    func bubbleStyle() -> some View {
        self.modifier(BubbleStyle())
    }
}
