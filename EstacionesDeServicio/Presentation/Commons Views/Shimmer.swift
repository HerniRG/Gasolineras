import SwiftUI

extension View {
    func shimmerEffect() -> some View {
        self
            .overlay(
                Shimmer()
                    .mask(self)
            )
    }
}

struct Shimmer: View {
    @State private var move = false

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.6), Color.clear]),
                       startPoint: .leading, endPoint: .trailing)
            .rotationEffect(.degrees(30))
            .offset(x: move ? 300 : -300)
            .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false), value: move)
            .onAppear {
                move = true
            }
    }
}
