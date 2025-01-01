import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var viewModel: GasolinerasViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Sección de Depósito de Combustible
                    SectionView(header: "Depósito de Combustible") {
                        VStack(alignment: .leading) {
                            Text("Litros del Depósito")
                                .font(.headline)
                            
                            Slider(value: $viewModel.fuelTankLiters, in: 10...100, step: 1)
                                .accentColor(.blue)
                            
                            Text("\(Int(viewModel.fuelTankLiters)) Litros")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Sección de Tipo de Combustible
                    SectionView(header: "Tipo de Combustible") {
                        FuelSelectionGrid(selectedFuelType: $viewModel.selectedFuelType)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Preferencias")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Vista de Sección Reutilizable
struct SectionView<Content: View>: View {
    let header: String
    let content: () -> Content
    
    init(header: String, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(header)
                .font(.headline)
            content()
        }
    }
}

struct PreferencesView_Previews: PreviewProvider {
    @State static var selectedFuelType: FuelType? = .gasolina95
    
    static var previews: some View {
        PreferencesView()
            .environmentObject(GasolinerasViewModel())
    }
}
