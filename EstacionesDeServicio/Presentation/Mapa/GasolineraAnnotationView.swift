import SwiftUI

struct GasolineraAnnotationView: View {
    let gasolinera: Gasolinera
    let selectedFuelType: FuelType // Cambiado de String a FuelType
    
    var body: some View {
        VStack(spacing: 4) {
            // Icono de la gasolinera
            Image("gasolineraIcon")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(radius: 4)
            
            // Precio del combustible seleccionado
            if let precio = gasolinera.price(for: selectedFuelType) {
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
}
