import SwiftUI

struct GasolineraAnnotationView: View {
    let gasolinera: Gasolinera
    let selectedFuelType: String
    
    var body: some View {
        VStack(spacing: 4) {
            // Icono del combustible
            Image("gasolineraIcon")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(radius: 4)
            
            // Precio del combustible seleccionado
            if let precio = precioSeleccionado {
                Text("\(precio, specifier: "%.3f") €")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(5)
            }
        }
    }
    
    /// Calcula el precio del combustible seleccionado
    private var precioSeleccionado: Double? {
        switch selectedFuelType {
        case "Gasolina 95":
            return gasolinera.precioGasolina95
        case "Gasolina 98":
            return gasolinera.precioGasolina98
        case "Gasóleo A":
            return gasolinera.precioGasoleoA
        case "GLP":
            return gasolinera.precioGLP
        case "Gasóleo Premium":
            return gasolinera.precioGasoleoPremium
        default:
            return gasolinera.precioGasolina95
        }
    }
}
