import SwiftUI

struct RootView: View {
    @AppStorage("onboardingCompleted") private var onboardingCompleted = false
    @Namespace private var animationNamespace
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    var body: some View {
        ZStack {
            if onboardingCompleted {
                GasolinerasView()
                    .matchedGeometryEffect(id: "transition", in: animationNamespace)
                    .transition(.opacity)
            } else {
                OnboardingView()
                    .matchedGeometryEffect(id: "transition", in: animationNamespace)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: onboardingCompleted)
    }
}


//preview
#Preview {
    
    RootView()
        .environmentObject(GasolinerasViewModel())
}
