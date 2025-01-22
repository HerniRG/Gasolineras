import SwiftUI

struct DepositSliderView: View {
    @Binding var fuelTankLiters: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Litros del Depósito")
                .font(.headline)
            
            Slider(value: $fuelTankLiters, in: 10...100, step: 1)
                .accentColor(.blue)
            
            Text("\(Int(fuelTankLiters)) Litros")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}
