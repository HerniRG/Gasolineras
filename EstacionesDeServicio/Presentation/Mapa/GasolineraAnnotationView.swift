import SwiftUI

struct GasolineraAnnotationView: View {
    let gasolinera: Gasolinera
    let selectedFuelType: FuelType
    let isCheapest: Bool // Nuevo parámetro

    var body: some View {
        ZStack {
            // Icono principal de la gasolinera
            Image("gasolineraIcon") // Icono de gota al revés
                .resizable()
                .frame(width: 35, height: 35) // Tamaño constante
                .foregroundColor(.green) // Color principal es verde
                .shadow(color: isCheapest ? Color.yellow.opacity(0.6) : Color.black.opacity(0.3), radius: isCheapest ? 6 : 4) // Sombreado ajustado
            
            // Añadir un badge si es la más económica
            if isCheapest {
                Image(systemName: "dollarsign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18) // Tamaño ligeramente más grande
                    .foregroundColor(.green) // Color distintivo para el badge
                    .background(Color.white) // Fondo blanco para destacar
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.primary.opacity(0.4), lineWidth: 0.5) // Borde fino de color .primary
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 2) // Sombra del badge
                    .offset(x: 15, y: -15) // Posición ajustada más cerca del icono
            }
            
            // Precio del combustible seleccionado
            if let precio = gasolinera.price(for: selectedFuelType) {
                Text("\(precio, specifier: "%.3f") €")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(5)
                    .offset(y: 25) // Posicionar el precio debajo del icono
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityLabel))
    }
    
    private var accessibilityLabel: String {
        var label = "Gasolinera: \(gasolinera.rotulo), \(gasolinera.localidad)"
        if isCheapest {
            label += ", más económica en tu radio"
        }
        if let precio = gasolinera.price(for: selectedFuelType) {
            let formattedPrice = String(format: "%.3f", precio)
            label += ", precio de \(selectedFuelType.rawValue): \(formattedPrice) euros"
        }
        return label
    }
}
