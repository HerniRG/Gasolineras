import SwiftUI

struct FuelSelectionGrid: View {
    @Binding var selectedFuelType: FuelType
    
    let spacing: CGFloat = 8
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(FuelType.allCases) { fuel in
                Button(action: {
                    withAnimation {
                        selectedFuelType = fuel
                    }
                }) {
                    VStack(spacing: 6) { // Espaciado reducido
                        // Ícono representativo de cada combustible
                        Image(systemName: iconName(for: fuel))
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(selectedFuelType == fuel ? .white : color(for: fuel))
                        
                        Text(fuel.displayName)
                            .font(.caption) // Fuente más pequeña
                            .bold()
                            .foregroundColor(selectedFuelType == fuel ? .white : .primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(6) // Padding reducido
                    .frame(maxWidth: .infinity, minHeight: 100) // Altura mínima ajustada
                    .background(selectedFuelType == fuel ? color(for: fuel) : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedFuelType == fuel ? color(for: fuel) : Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(fuel.displayName)
            }
        }
        .padding(.horizontal, spacing)
        .padding(.vertical, spacing / 2)
    }
    
    // Columnas adaptativas para ajustar automáticamente el número de columnas según el ancho disponible
    var columns: [GridItem] {
        let count: Int
        if horizontalSizeClass == .compact {
            count = 4 // 4 columnas en iPhones
        } else {
            count = 5 // 5 columnas en iPads
        }
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
    
    // Tamaño fijo para los íconos, ajustable según preferencia
    var iconSize: CGFloat {
        horizontalSizeClass == .compact ? 30 : 35
    }
    
    // Asigna un color específico a cada tipo de combustible
    func color(for fuel: FuelType) -> Color {
        switch fuel {
        case .gasolina95, .gasolina98, .gasoleoA, .gasoleoPremium:
            return Color.red
        case .glp:
            return Color.orange
        case .gnc, .gnl:
            return Color.green
        case .hidrogeno:
            return Color.blue
        case .bioetanol, .biodiesel:
            return Color.purple
        case .esterMetilico:
            return Color.teal
        }
    }
    
    // Asigna íconos a cada tipo de combustible
    func iconName(for fuel: FuelType) -> String {
        switch fuel {
        case .gasolina95, .gasolina98, .gasoleoA, .gasoleoPremium:
            return "fuelpump.fill"
        case .glp:
            return "flame.fill"
        case .gnc, .gnl:
            return "leaf.fill" // Ícono representativo genérico para GNC/GNL
        case .hidrogeno:
            return "bolt.fill" // Ícono genérico para Hidrógeno
        case .bioetanol, .biodiesel:
            return "drop.fill" // Ícono genérico para Bioetanol/Biodiesel
        case .esterMetilico:
            return "hexagon.fill" // Ícono genérico para Éster Metílico
        }
    }
}

struct FuelSelectionGrid_Previews: PreviewProvider {
    @State static var selectedFuelType: FuelType = .gasolina95

    static var previews: some View {
        Group {
            FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                .previewDevice("iPhone SE (2nd generation)")
                .previewDisplayName("iPhone SE")
            
            FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                .previewDevice("iPhone 14 Pro Max")
                .previewDisplayName("iPhone 14 Pro Max")
            
            FuelSelectionGrid(selectedFuelType: $selectedFuelType)
                .previewDevice("iPad Pro (11-inch) (4th generation)")
                .previewDisplayName("iPad Pro")
        }
        .previewLayout(.sizeThatFits)
    }
}
