import SwiftUI

struct PrecioResumenView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Línea de texto con icono que indica el radio
            HStack(alignment: .center, spacing: 5) {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                
                Text("Datos a un radio \(viewModel.radius, specifier: "%.2f") km de tu ubicación")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // Datos de Precio Promedio y Gasolineras Disponibles
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Precio medio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.calcularPromedioEnRadio(), specifier: "%.3f") €")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Gasolineras disponibles")
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
