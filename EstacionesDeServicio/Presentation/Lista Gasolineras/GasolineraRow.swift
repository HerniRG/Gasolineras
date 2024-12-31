import SwiftUI

struct GasolineraRow: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel // Acceso al ViewModel
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
            let fuelPrices = sortedFuelPrices()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(fuelPrices, id: \.fuelType) { fuelPrice in
                        FuelPrice(fuelType: fuelPrice.fuelType, price: fuelPrice.price)
                    }
                }
                .padding(EdgeInsets(top: 8, leading: 2, bottom: 2, trailing: 2))
            }
        }
        .padding(.vertical, 8)
    }
    
    // Organizar los combustibles, priorizando el seleccionado por el usuario
    private func sortedFuelPrices() -> [(fuelType: FuelType, price: Double)] {
        var fuelPrices: [(fuelType: FuelType, price: Double)] = []
        
        if let precio95 = gasolinera.precioGasolina95 {
            fuelPrices.append((.gasolina95, precio95))
        }
        if let precio98 = gasolinera.precioGasolina98 {
            fuelPrices.append((.gasolina98, precio98))
        }
        if let precioGasoleoA = gasolinera.precioGasoleoA {
            fuelPrices.append((.gasoleoA, precioGasoleoA))
        }
        if let precioPremium = gasolinera.precioGasoleoPremium {
            fuelPrices.append((.gasoleoPremium, precioPremium))
        }
        if let precioGLP = gasolinera.precioGLP {
            fuelPrices.append((.glp, precioGLP))
        }
        
        // Priorizar el combustible seleccionado
        return fuelPrices.sorted { lhs, rhs in
            if lhs.fuelType == viewModel.selectedFuelType {
                return true
            }
            if rhs.fuelType == viewModel.selectedFuelType {
                return false
            }
            return lhs.fuelType.rawValue < rhs.fuelType.rawValue // Orden alfabético para los demás
        }
    }
}
