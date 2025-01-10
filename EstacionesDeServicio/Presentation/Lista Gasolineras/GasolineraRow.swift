import SwiftUI

struct GasolineraRow: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
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
            
            // Muestra solamente el tipo de combustible seleccionado
            if let selectedFuelPrice = getSelectedFuelPrice() {
                // Vista personalizada del precio, con layout horizontal
                HStack {
                    FuelPrice(
                        fuelType: viewModel.selectedFuelType,
                        price: selectedFuelPrice,
                        isHorizontal: true
                    )
                    .padding(.vertical, 8)
                    
                    // Cálculo del costo de llenado
                    VStack(alignment: .leading, spacing: 8) {
                        // Cálculo del costo de llenado
                        Text("\(costoLlenado(selectedFuelPrice), specifier: "%.2f") € / llenado (\(Int(viewModel.fuelTankLiters)) l)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                        
                        // Nuevo texto para el promedio
                        Text("\(viewModel.calcularPromedioEnRadio(), specifier: "%.3f") € / l promedio en \(Int(viewModel.radius)) km")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }
                }
            } else {
                Text("El tipo de combustible seleccionado no está disponible.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
    
    /// Devuelve el precio del combustible seleccionado por el usuario (si existe).
    private func getSelectedFuelPrice() -> Double? {
        switch viewModel.selectedFuelType {
        case .gasolina95:
            return gasolinera.precioGasolina95
        case .gasolina98:
            return gasolinera.precioGasolina98
        case .gasoleoA:
            return gasolinera.precioGasoleoA
        case .gasoleoPremium:
            return gasolinera.precioGasoleoPremium
        case .glp:
            return gasolinera.precioGLP
        case .gnc:
            return gasolinera.precioGNC
        case .gnl:
            return gasolinera.precioGNL
        case .hidrogeno:
            return gasolinera.precioHidrogeno
        case .bioetanol:
            return gasolinera.precioBioetanol
        case .biodiesel:
            return gasolinera.precioBiodiesel
        case .esterMetilico:
            return gasolinera.precioEsterMetilico
        }
    }
    
    /// Calcula el costo de llenado basado en el tamaño del depósito y el precio por litro.
    private func costoLlenado(_ precioPorLitro: Double) -> Double {
        return precioPorLitro * viewModel.fuelTankLiters
    }
}

