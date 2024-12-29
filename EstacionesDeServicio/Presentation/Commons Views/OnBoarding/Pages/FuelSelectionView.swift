import SwiftUI

struct FuelSelectionView: View {
    @Binding var selectedFuelType: FuelType?
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
                if selectedFuelType != nil {
                    onFinish()
                }
            }) {
                Text("Finalizar")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedFuelType != nil ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .disabled(selectedFuelType == nil)
        }
        .padding()
    }
}

struct FuelSelectionView_Previews: PreviewProvider {
    @State static var selectedFuelType: FuelType? = nil
    
    static var previews: some View {
        FuelSelectionView(selectedFuelType: $selectedFuelType) {
            print("Finalizar presionado")
        }
    }
}
