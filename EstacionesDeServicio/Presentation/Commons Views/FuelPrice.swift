import SwiftUI

struct FuelPrice: View {
    let fuelType: String
    let price: Double
    var isHorizontal: Bool = false // Parámetro opcional, por defecto vertical
    
    var body: some View {
        Group {
            if isHorizontal {
                // Diseño Horizontal
                HStack {
                    Text(fuelType)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("\(price, specifier: "%.3f") €")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(width: 140)
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
            } else {
                // Diseño Vertical (por defecto)
                VStack {
                    Text(fuelType)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("\(price, specifier: "%.3f") €")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(width: 80) // Ajusta el ancho para alineación
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
            }
        }
    }
    
    /// Indicador de color para diseño horizontal
    private var colorIndicator: some View {
        Circle()
            .fill(backgroundColor)
            .frame(width: 12, height: 12)
    }
    
    /// Ajusta los colores según combustibles habituales
    private var backgroundColor: Color {
        switch fuelType {
        case "Gasolina 95":
            return .green.opacity(0.2)
        case "Gasolina 98":
            return .blue.opacity(0.2)
        case "Gasóleo A":
            return .orange.opacity(0.2)
        case "GLP":
            return .purple.opacity(0.2)
        default:
            return .gray.opacity(0.2)
        }
    }
}
