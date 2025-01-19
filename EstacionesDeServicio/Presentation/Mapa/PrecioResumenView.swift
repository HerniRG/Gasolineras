import SwiftUI

struct PrecioResumenView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Línea de texto con icono que indica el radio
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text("Datos dentro de un radio de \(viewModel.radius, specifier: "%.2f") km")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // Datos de Precio Promedio y Gasolineras Disponibles
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Precio Promedio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.calcularPromedioEnRadio(), specifier: "%.3f") €")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gasolineras Disponibles")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.filteredGasolineras.count)")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .bubbleStyle()
        .padding([.leading, .trailing, .bottom], 10)
    }
}
