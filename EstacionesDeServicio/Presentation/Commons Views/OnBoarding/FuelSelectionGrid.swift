// FuelSelectionGrid.swift
import SwiftUI

struct FuelSelectionGrid: View {
    @Binding var selectedFuelType: FuelType?
    
    // Definir una cuadrícula de 2 columnas
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(FuelType.allCases) { fuel in
                Button(action: {
                    withAnimation {
                        if selectedFuelType == fuel {
                            // Si ya está seleccionado, deselecciona
                            selectedFuelType = nil
                        } else {
                            selectedFuelType = fuel
                        }
                    }
                }) {
                    VStack {
                        // Reemplaza con íconos representativos de cada combustible
                        Image(systemName: iconName(for: fuel))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(selectedFuelType == fuel ? .white : .blue)
                        
                        Text(fuel.rawValue)
                            .font(.headline)
                            .foregroundColor(selectedFuelType == fuel ? .white : .blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedFuelType == fuel ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedFuelType == fuel ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
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
        case .glp:
            return "flame.fill" // Ejemplo de ícono diferente
        }
    }
}

struct FuelSelectionGrid_Previews: PreviewProvider {
    @State static var selectedFuelType: FuelType? = nil
    
    static var previews: some View {
        FuelSelectionGrid(selectedFuelType: $selectedFuelType)
    }
}
