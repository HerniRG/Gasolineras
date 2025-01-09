import SwiftUI

struct FuelSelectionView: View {
    @Binding var selectedFuelType: FuelType
    var onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Selecciona tu combustible")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Elige el tipo de combustible que usas más frecuentemente.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Nota Informativa sobre la Disponibilidad de Combustibles
            Text("⚠️ **Nota:** Algunos combustibles pueden tener disponibilidad limitada en ciertas estaciones.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            // Cuadrícula de Selección
            FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onFinish()
            }) {
                Text("Finalizar")
                    .font(.headline)
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

struct FuelSelectionView_Previews: PreviewProvider {
    @State static var selectedFuelType: FuelType = .gasolina95
    
    static var previews: some View {
        Group {
            FuelSelectionView(selectedFuelType: $selectedFuelType, onFinish: {
                print("Finalizar presionado")
            })
            .previewDevice("iPhone SE (2nd generation)")
            .previewDisplayName("iPhone SE")
            
            FuelSelectionView(selectedFuelType: $selectedFuelType, onFinish: {
                print("Finalizar presionado")
            })
            .previewDevice("iPhone 14 Pro Max")
            .previewDisplayName("iPhone 14 Pro Max")
            
            FuelSelectionView(selectedFuelType: $selectedFuelType, onFinish: {
                print("Finalizar presionado")
            })
            .previewDevice("iPad Pro (11-inch) (4th generation)")
            .previewDisplayName("iPad Pro")
        }
        .previewLayout(.sizeThatFits)
    }
}
