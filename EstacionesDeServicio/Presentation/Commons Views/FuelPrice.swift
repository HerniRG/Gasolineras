import SwiftUI

struct FuelPrice: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel // Acceso al ViewModel
    let fuelType: FuelType
    let price: Double
    var isHorizontal: Bool = false // Parámetro opcional, por defecto vertical
    
    var body: some View {
        // Determinar si este combustible está seleccionado
        let isSelected = fuelType == viewModel.selectedFuelType
        
        Group {
            if isHorizontal {
                // Diseño Horizontal
                HStack {
                    Text(fuelType.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 100, alignment: .leading) // Fuerza mismo ancho para todos
                    Spacer()
                    Text("\(price, specifier: "%.3f") €")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Asegura que el HStack completo esté alineado
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
                // Aplicar borde especial si está seleccionado
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                // Añadir una sombra para mayor énfasis
                .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 4, x: 0, y: 0)
            } else {
                // Diseño Vertical (por defecto)
                VStack {
                    Text(fuelType.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    Text("\(price, specifier: "%.3f") €")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
                // Aplicar borde especial si está seleccionado
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                // Añadir una sombra para mayor énfasis
                .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 4, x: 0, y: 0)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected) // Animación suave al cambiar el estado
    }
    
    /// Ajusta los colores según combustibles habituales
    private var backgroundColor: Color {
        switch fuelType {
        case .gasolina95:
            return Color.green.opacity(0.2) // Combustible fósil
        case .gasolina98:
            return Color.blue.opacity(0.2) // Combustible fósil
        case .gasoleoA:
            return Color.orange.opacity(0.2) // Combustible fósil
        case .gasoleoPremium:
            return Color.yellow.opacity(0.2) // Combustible fósil
        case .glp:
            return Color.purple.opacity(0.2) // GLP
        case .gnc:
            return Color.teal.opacity(0.2) // Gas Natural Comprimido
        case .gnl:
            return Color.teal.opacity(0.2) // Gas Natural Licuado
        case .hidrogeno:
            return Color.blue.opacity(0.2) // Hidrógeno
        case .bioetanol:
            return Color.purple.opacity(0.2) // Bioetanol
        case .biodiesel:
            return Color.purple.opacity(0.2) // Biodiesel
        case .esterMetilico:
            return Color.teal.opacity(0.2) // Éster Metílico
        }
    }
}
