import SwiftUI

struct FuelSelectionView: View {
    @Binding var selectedFuelType: FuelType
    @Binding var fuelTankLiters: Double
    var onFinish: () -> Void

    var body: some View {
        ScrollView { // Añadir ScrollView aquí
            VStack(spacing: 10) {
                Text("Selecciona tu combustible y depósito")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.top) // Añadir padding superior si es necesario

                Text("Elige el tipo de combustible que usas más frecuentemente y capacidad de depósito.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Nota Informativa sobre la Disponibilidad de Combustibles
                Text("⚠️ **Nota:** Algunos combustibles pueden tener disponibilidad limitada en ciertas estaciones.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Cuadrícula de Selección
                FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                    .padding(.horizontal)

                // Integración de DepositSliderView con Padding Horizontal
                DepositSliderView(fuelTankLiters: $fuelTankLiters)
                    .padding(.horizontal)

                Spacer(minLength: 20) // Añadir un poco de espacio antes del botón

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
                .padding(.bottom) // Añadir padding inferior si es necesario
            }
            .padding() // Padding general
        }
    }
}
