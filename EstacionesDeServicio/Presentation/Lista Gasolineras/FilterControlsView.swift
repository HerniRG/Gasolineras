import SwiftUI

struct FilterControlsView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @State private var tempRadius: Double = 5.0 // Variable temporal para el slider

    var body: some View {
        VStack(spacing: 10) {
            // Segmented Control para opciones de ordenación
            Picker("Ordenar por", selection: $viewModel.sortOption) {
                ForEach(SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Slider para el radio de búsqueda
            VStack(alignment: .leading) {
                Text("Radio: \(Int(tempRadius)) km")
                    .font(.caption)
                Slider(
                    value: $tempRadius,
                    in: 1...20,
                    step: 1,
                    onEditingChanged: { editing in
                        if !editing {
                            // Cuando el usuario suelta el slider, actualiza el radius en el ViewModel
                            viewModel.radius = tempRadius
                        }
                    }
                )
                .accentColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .onAppear {
            // Inicializa el tempRadius con el valor actual del ViewModel
            self.tempRadius = viewModel.radius
        }
        .onChange(of: viewModel.radius) { newRadius in
            // Si el radius en el ViewModel cambia por otra causa, actualiza el tempRadius
            self.tempRadius = newRadius
        }
    }
}
