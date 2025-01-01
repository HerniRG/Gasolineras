import SwiftUI

struct FuelSelectionGrid: View {
    @Binding var selectedFuelType: FuelType
    
    // Definir una cuadrícula de 2 columnas
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(FuelType.allCases) { fuel in
                Button(action: {
                    withAnimation {
                        selectedFuelType = fuel
                    }
                }) {
                    VStack {
                        // Reemplaza con íconos representativos de cada combustible
                        Image(systemName: iconName(for: fuel))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundColor(selectedFuelType == fuel ? .white : .blue)
                        
                        Text(fuel.rawValue)
                            .font(.headline)
                            .foregroundColor(selectedFuelType == fuel ? .white : .blue)
                            .multilineTextAlignment(.center)
                    }
                    
                    .frame(maxWidth: .infinity)
                    .frame(height: 100)
                    .background(selectedFuelType == fuel ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedFuelType == fuel ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .accessibilityLabel(fuel.displayName)
            }
        }
    }
    
    // Función para asignar íconos a cada tipo de combustible
    func iconName(for fuel: FuelType) -> String {
        switch fuel {
        case .gasolina95:
            return "fuelpump.fill"
        case .gasolina98:
            return "fuelpump.fill"
        case .gasoleoA:
            return "fuelpump.fill"
        case .gasoleoPremium:
            return "fuelpump.fill"
        case .glp:
            return "flame.fill"
        }
    }
}
