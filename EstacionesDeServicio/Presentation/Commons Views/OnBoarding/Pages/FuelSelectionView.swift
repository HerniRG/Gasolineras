import SwiftUI

struct FuelSelectionView: View {
    @Binding var selectedFuelType: FuelType
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Selecciona tu combustible")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Elige el tipo de combustible que usas más frecuentemente.")
                .multilineTextAlignment(.center)
                .padding()
            
            // Cuadrícula de Selección
            FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                .padding()
            
            Spacer()
            
            Button(action: {
                onFinish()
            }) {
                Text("Finalizar")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
