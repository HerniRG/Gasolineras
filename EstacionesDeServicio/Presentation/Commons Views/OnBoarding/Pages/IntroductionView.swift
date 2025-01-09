import SwiftUI
//import Lottie

struct IntroductionView: View {
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Bienvenido a Tu Gasolinera")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Encuentra las gasolineras más cercanas y ahorra en cada repostaje.")
                .multilineTextAlignment(.center)
                .padding()
            
//            LottieView(animation: .named("welcome"))
//                .looping()
//                .frame(height: 300)
            
            Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                Text("Animación aquí")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            )
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    onNext()
                }
            }) {
                Text("Siguiente")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView {
            print("Siguiente presionado")
        }
    }
}
