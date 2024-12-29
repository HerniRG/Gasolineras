import SwiftUI

struct GasolineraRow: View {
    let gasolinera: Gasolinera

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cabecera
            HStack {
                Text(gasolinera.rotulo)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if let distancia = gasolinera.distancia {
                    Text("\(distancia / 1000, specifier: "%.2f") km")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            // Dirección
            Text("\(gasolinera.direccion), \(gasolinera.localidad)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Combustibles
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if let precio95 = gasolinera.precioGasolina95 {
                        FuelPrice(fuelType: "Gasolina 95", price: precio95)
                    }
                    if let precio98 = gasolinera.precioGasolina98 {
                        FuelPrice(fuelType: "Gasolina 98", price: precio98)
                    }
                    if let precioGasoleoA = gasolinera.precioGasoleoA {
                        FuelPrice(fuelType: "Gasóleo A", price: precioGasoleoA)
                    }
                    if let precioGLP = gasolinera.precioGLP {
                        FuelPrice(fuelType: "GLP", price: precioGLP)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
    }
}
